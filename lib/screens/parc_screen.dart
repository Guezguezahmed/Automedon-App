import 'package:flutter/material.dart';
import '../theme.dart';

// ---------------------------------------------------------------------------
// TODO(backend): L'API mobile est en lecture seule (voir MOBILE_API.md).
// Il n'existe ni endpoint pour lister les parcs, ni pour changer le parc
// d'une voiture. Cet écran utilise donc un état LOCAL (le déplacement
// fonctionne dans l'app mais n'est pas sauvegardé côté serveur).
//
// Quand le backend exposera par ex.:
//   GET   /mobile-parcs            -> liste des parcs + voitures
//   POST  /mobile-parcs            -> { "name": "...", "location": "..." }
//   PATCH /mobile-cars/:id/parc    -> { "parc_id": "..." }
// remplacer `_parcs` (state local) par un vrai fetch au initState(), et
// appeler les endpoints POST/PATCH dans `_addParc`/`_moveCar` avant/après
// la mise à jour locale (rollback si l'appel échoue).
//
// Le bouton "Historique" est un placeholder pour l'instant : aucun
// mouvement (même local) n'est actuellement journalisé. À implémenter
// une fois qu'on sait où ces données doivent vivre (log local en mémoire
// en attendant le backend, ou vrai endpoint une fois disponible).
// ---------------------------------------------------------------------------

class ParcCar {
  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final String status; // 'disponible' | 'loue' | 'maintenance'
  final String? imageUrl;

  const ParcCar({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.status,
    this.imageUrl,
  });
}

class Parc {
  final String id;
  final String name;
  final String location;
  final List<ParcCar> cars;

  const Parc({
    required this.id,
    required this.name,
    required this.location,
    required this.cars,
  });

  Parc copyWith({List<ParcCar>? cars}) =>
      Parc(id: id, name: name, location: location, cars: cars ?? this.cars);
}

class ParcsScreen extends StatefulWidget {
  const ParcsScreen({super.key});

  @override
  State<ParcsScreen> createState() => _ParcsScreenState();
}

class _ParcsScreenState extends State<ParcsScreen> {
  static const String unassignedId = 'unassigned';

  List<Parc> _parcs = [
    const Parc(
      id: 'parc1',
      name: 'Parc1',
      location: 'Msaken',
      cars: [
        ParcCar(id: 'c1', brand: 'Hyundai', model: 'I20', plateNumber: '257TU3965', status: 'disponible'),
        ParcCar(id: 'c2', brand: 'Suzuki', model: 'Ciaz', plateNumber: '242TN7442', status: 'disponible'),
        ParcCar(id: 'c3', brand: 'Volkswagen', model: 'Virtus', plateNumber: '239TN5845', status: 'disponible'),
      ],
    ),
    const Parc(
      id: 'parc2',
      name: 'Parc2',
      location: 'Msaken',
      cars: [
        ParcCar(id: 'c4', brand: 'Renault', model: 'Clio 5', plateNumber: '247TN6228', status: 'disponible'),
      ],
    ),
    const Parc(
      id: unassignedId,
      name: 'À assigner',
      location: '',
      cars: [
        ParcCar(id: 'c5', brand: 'Dacia', model: 'Sindero', plateNumber: '237TU4530', status: 'disponible'),
        ParcCar(id: 'c6', brand: 'Hyundai', model: 'I20', plateNumber: '247TN5433', status: 'disponible'),
        ParcCar(id: 'c7', brand: 'Skoda', model: 'Kushaq', plateNumber: '252TN9505', status: 'loue'),
        ParcCar(id: 'c8', brand: 'Volkswagen', model: 'Virtus', plateNumber: '239TN5844', status: 'loue'),
      ],
    ),
  ];

  int get _totalCars => _parcs.fold<int>(0, (s, p) => s + p.cars.length);
  int get _placedCars =>
      _parcs.where((p) => p.id != unassignedId).fold<int>(0, (s, p) => s + p.cars.length);
  int get _unassignedCount => _parcs.firstWhere((p) => p.id == unassignedId).cars.length;

  void _moveCar(ParcCar car, String fromParcId, String toParcId) {
    if (fromParcId == toParcId) return;
    setState(() {
      _parcs = _parcs.map((p) {
        if (p.id == fromParcId) {
          return p.copyWith(cars: p.cars.where((c) => c.id != car.id).toList());
        }
        if (p.id == toParcId) {
          return p.copyWith(cars: [...p.cars, car]);
        }
        return p;
      }).toList();
    });

    // TODO(backend): appeler PATCH /mobile-cars/:id/parc ici une fois dispo.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${car.brand} ${car.model} déplacée'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Ajoute un nouveau parc en état local -- entièrement fonctionnel côté
  // app puisque tout l'écran repose déjà sur un state local (pas besoin
  // d'attendre un endpoint POST /mobile-parcs pour que ça marche en démo).
  // L'ajout est inséré juste avant "À assigner", qui reste toujours en
  // dernière position.
  void _addParc(String name, String location) {
    final newParc = Parc(
      id: 'parc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      location: location,
      cars: const [],
    );
    setState(() {
      final unassignedIndex = _parcs.indexWhere((p) => p.id == unassignedId);
      _parcs = [
        ..._parcs.sublist(0, unassignedIndex),
        newParc,
        ..._parcs.sublist(unassignedIndex),
      ];
    });
  }

  Future<void> _showAddParcDialog() async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nouveau parc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Nom du parc'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(hintText: 'Localisation (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      _addParc(nameController.text.trim(), locationController.text.trim());
    }
  }

  void _openHistorique() {
    // TODO: brancher sur un vrai écran/flux d'historique des déplacements
    // une fois qu'on sait où cette donnée doit être journalisée (état
    // local en mémoire en attendant le backend, ou vrai endpoint).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique des déplacements — bientôt disponible'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warehouse_outlined, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parcs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  Text(
                    '$_totalCars voitures au total',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _openHistorique,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Historique', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: _showAddParcDialog,
              tooltip: 'Nouveau parc',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Parcs',
                    value: '${_parcs.length - 1}',
                    icon: Icons.warehouse_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Placées',
                    value: '$_placedCars',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'À assigner',
                    value: '$_unassignedCount',
                    icon: Icons.inbox_outlined,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Maintenez et glissez une voiture vers un autre parc',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _parcs.length,
              itemBuilder: (context, index) {
                final parc = _parcs[index];
                return _ParcColumn(
                  parc: parc,
                  onCarDropped: (car, fromParcId) => _moveCar(car, fromParcId, parc.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SummaryCard({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

typedef CarDroppedCallback = void Function(ParcCar car, String fromParcId);

class _ParcColumn extends StatefulWidget {
  final Parc parc;
  final CarDroppedCallback onCarDropped;

  const _ParcColumn({required this.parc, required this.onCarDropped});

  @override
  State<_ParcColumn> createState() => _ParcColumnState();
}

class _ParcColumnState extends State<_ParcColumn> {
  bool _hovering = false;

  bool get _isUnassigned => widget.parc.id == 'unassigned';

  @override
  Widget build(BuildContext context) {
    final headerColor = _isUnassigned ? AppTheme.warning : AppTheme.primary;

    return DragTarget<_DragPayload>(
      onWillAcceptWithDetails: (details) {
        setState(() => _hovering = true);
        return details.data.fromParcId != widget.parc.id;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        widget.onCarDropped(details.data.car, details.data.fromParcId);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 260,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: _isUnassigned ? AppTheme.warning.withOpacity(0.06) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering
                  ? headerColor
                  : (_isUnassigned ? AppTheme.warning.withOpacity(0.25) : const Color(0xFFE5E7EB)),
              width: _hovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    Icon(
                      _isUnassigned ? Icons.inbox_outlined : Icons.warehouse_outlined,
                      color: headerColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.parc.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: headerColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.parc.cars.length}',
                        style: TextStyle(color: headerColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.parc.location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        widget.parc.location,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: widget.parc.cars.isEmpty
                    ? Center(
                  child: Text(
                    _hovering ? 'Déposer ici' : 'Vide',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  itemCount: widget.parc.cars.length,
                  itemBuilder: (context, i) {
                    final car = widget.parc.cars[i];
                    return _DraggableCarTile(car: car, parcId: widget.parc.id);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragPayload {
  final ParcCar car;
  final String fromParcId;
  const _DragPayload(this.car, this.fromParcId);
}

class _DraggableCarTile extends StatelessWidget {
  final ParcCar car;
  final String parcId;

  const _DraggableCarTile({required this.car, required this.parcId});

  // Une voiture louée qui se trouve encore dans "À assigner" ne peut pas
  // être déplacée vers un parc tant qu'elle n'est pas rendue : on bloque
  // le drag et on affiche le même message d'avertissement que sur le web.
  bool get _isLockedInUnassigned => parcId == 'unassigned' && car.status == 'loue';

  void _showLockedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Voiture louée'),
        content: const Text(
          'Cette voiture est louée : elle reste dans « À assigner » jusqu\'à son retour.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLockedInUnassigned) {
      // Pas de LongPressDraggable ici : un simple appui long affiche le
      // message d'explication au lieu de démarrer un déplacement.
      return GestureDetector(
        onLongPress: () => _showLockedMessage(context),
        child: _CarTile(car: car, locked: true),
      );
    }

    return LongPressDraggable<_DragPayload>(
      data: _DragPayload(car, parcId),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 240, child: _CarTile(car: car, elevated: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _CarTile(car: car)),
      child: _CarTile(car: car),
    );
  }
}

class _CarTile extends StatelessWidget {
  final ParcCar car;
  final bool elevated;
  final bool locked;

  const _CarTile({required this.car, this.elevated = false, this.locked = false});

  Color get _statusColor {
    switch (car.status) {
      case 'disponible':
        return AppTheme.success;
      case 'loue':
        return AppTheme.primary;
      case 'maintenance':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _statusLabel {
    switch (car.status) {
      case 'disponible':
        return 'Disponible';
      case 'loue':
        return 'Loué';
      case 'maintenance':
        return 'Maintenance';
      default:
        return car.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF3F4F6) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: elevated
            ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              color: const Color(0xFFF3F4F6),
              child: car.imageUrl != null
                  ? Image.network(car.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.directions_car_outlined, color: AppTheme.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    car.plateNumber,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel,
                      style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            locked ? Icons.lock_outline : Icons.drag_indicator,
            color: AppTheme.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}