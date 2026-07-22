import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

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

final List<Parc> _initialParcs = [
  const Parc(
    id: 'unassigned',
    name: 'À assigner',
    location: '',
    cars: [
      ParcCar(id: 'c4', brand: 'Hyundai', model: 'I20', plateNumber: '190TN1234', status: 'disponible'),
      ParcCar(id: 'c5', brand: 'Fiat', model: 'Grand Punto', plateNumber: '210TN5678', status: 'disponible'),
      ParcCar(id: 'c6', brand: 'Renault', model: 'Clio 4', plateNumber: '215TN9999', status: 'loue'),
      ParcCar(id: 'c7', brand: 'Seat', model: 'Ibiza', plateNumber: '220TN0000', status: 'maintenance'),
    ],
  ),
  const Parc(
    id: 'parc-1',
    name: 'Parc1',
    location: 'Msaken',
    cars: [
      ParcCar(id: 'c1', brand: 'Hyundai', model: 'I20', plateNumber: '257TU3965', status: 'disponible'),
      ParcCar(id: 'c2', brand: 'Suzuki', model: 'Ciaz', plateNumber: '242TN7442', status: 'disponible'),
      ParcCar(id: 'c3', brand: 'Volkswagen', model: 'Virtus', plateNumber: '239TN5845', status: 'disponible'),
    ],
  ),
  const Parc(
    id: 'parc-2',
    name: 'Parc2',
    location: 'Msaken',
    cars: [
      ParcCar(id: 'c8', brand: 'Renault', model: 'CLIO 5', plateNumber: '247TN1111', status: 'disponible'),
    ],
  ),
];

class ParcsScreen extends StatefulWidget {
  const ParcsScreen({super.key});

  @override
  State<ParcsScreen> createState() => _ParcsScreenState();
}

class _ParcsScreenState extends State<ParcsScreen> {
  late List<Parc> _parcs;

  @override
  void initState() {
    super.initState();
    _parcs = List.from(_initialParcs);
  }

  int get _totalCars => _parcs.fold(0, (sum, p) => sum + p.cars.length);

  int get _unassignedCount {
    final unassigned = _parcs.firstWhere((p) => p.id == 'unassigned', orElse: () => _initialParcs.first);
    return unassigned.cars.length;
  }

  int get _placedCars => _totalCars - _unassignedCount;

  void _moveCar(ParcCar car, String fromParcId, String toParcId) {
    if (fromParcId == toParcId) return;

    if (fromParcId == 'unassigned' && car.status == 'loue') {
      _showLockedSnackbar();
      return;
    }

    setState(() {
      _parcs = _parcs.map((parc) {
        if (parc.id == fromParcId) {
          final updated = parc.cars.where((c) => c.id != car.id).toList();
          return parc.copyWith(cars: updated);
        }
        if (parc.id == toParcId) {
          final updated = List<ParcCar>.from(parc.cars)..add(car);
          return parc.copyWith(cars: updated);
        }
        return parc;
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${car.brand} ${car.model} déplacée'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLockedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voiture louée : déplacement impossible'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddParcDialog() {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          title: Text('Nouveau parc', style: AppTextStyles.displayMd(color: isDark ? Colors.white : AppTheme.ink900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
                decoration: InputDecoration(
                  labelText: 'Nom du parc',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : AppTheme.ink600),
                  hintText: 'ex: Parc Sousse',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.ink400),
                ),
              ),
              const SizedBox(height: AppTheme.sp3),
              TextField(
                controller: locCtrl,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
                decoration: InputDecoration(
                  labelText: 'Emplacement',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : AppTheme.ink600),
                  hintText: 'ex: Zone Industrielle',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.ink400),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler', style: AppTextStyles.bodyLg(color: isDark ? Colors.white60 : AppTheme.ink600)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _parcs.add(Parc(
                    id: 'parc-${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    location: locCtrl.text.trim(),
                    cars: [],
                  ));
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  void _openHistorique() {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
          title: Row(
            children: [
              AppIconCircle(
                icon: Icons.warehouse_outlined,
                color: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                size: 38,
                hasGlow: isDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parcs',
                      style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900),
                    ),
                    Text(
                      '$_totalCars voitures au total',
                      style: AppTextStyles.caption(color: isDark ? Colors.white60 : AppTheme.ink600),
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
                foregroundColor: isDark ? Colors.white : AppTheme.ink900,
                side: BorderSide(
                  color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(Icons.history, size: 16, color: isDark ? Colors.white70 : AppTheme.ink600),
              label: const Text('Historique', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? [BoxShadow(color: AppTheme.neonViolet.withValues(alpha: 0.4), blurRadius: 10)]
                    : null,
              ),
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
              padding: const EdgeInsets.fromLTRB(AppTheme.sp4, AppTheme.sp2, AppTheme.sp4, AppTheme.sp1),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Parcs',
                      value: '${_parcs.length - 1}',
                      icon: Icons.warehouse_outlined,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppTheme.sp3),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Placées',
                      value: '$_placedCars',
                      icon: Icons.check_circle_outline,
                      color: isDark ? AppTheme.neonMint : AppTheme.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppTheme.sp3),
                  Expanded(
                    child: _SummaryCard(
                      label: 'À assigner',
                      value: '$_unassignedCount',
                      icon: Icons.inbox_outlined,
                      color: AppTheme.warning,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.sp2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp4),
              child: AppInfoBanner(
                message: 'Maintenez et glissez une voiture vers un autre parc',
                icon: Icons.drag_indicator,
              ),
            ),
            const SizedBox(height: AppTheme.sp2),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.sp4,
                  AppTheme.sp2,
                  AppTheme.sp4,
                  120,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _parcs.length,
                itemBuilder: (context, index) {
                  final parc = _parcs[index];
                  return _ParcColumn(
                    parc: parc,
                    isDark: isDark,
                    onCarDropped: (car, fromParcId) => _moveCar(car, fromParcId, parc.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppTheme.neonViolet : AppTheme.primary600);
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp3),
      hasGlow: isDark,
      glowColor: isDark ? c : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconCircle(
            icon: icon,
            color: c,
            size: 32,
            iconSize: 16,
            hasGlow: isDark,
          ),
          const SizedBox(height: AppTheme.sp2),
          Text(
            value,
            style: AppTextStyles.dataLg(color: isDark ? Colors.white : AppTheme.ink900),
          ),
          Text(
            label,
            style: AppTextStyles.caption(color: isDark ? Colors.white70 : AppTheme.ink600),
          ),
        ],
      ),
    );
  }
}

typedef CarDroppedCallback = void Function(ParcCar car, String fromParcId);

class _ParcColumn extends StatefulWidget {
  final Parc parc;
  final bool isDark;
  final CarDroppedCallback onCarDropped;

  const _ParcColumn({required this.parc, required this.isDark, required this.onCarDropped});

  @override
  State<_ParcColumn> createState() => _ParcColumnState();
}

class _ParcColumnState extends State<_ParcColumn> {
  bool _hovering = false;

  bool get _isUnassigned => widget.parc.id == 'unassigned';

  @override
  Widget build(BuildContext context) {
    final headerColor = _isUnassigned
        ? AppTheme.warning
        : (widget.isDark ? AppTheme.neonViolet : AppTheme.primary600);

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
          width: 280,
          margin: const EdgeInsets.only(right: AppTheme.sp3),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppTheme.darkSurface
                : (_isUnassigned ? AppTheme.warning.withValues(alpha: 0.04) : AppTheme.surface0),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: widget.isDark
                ? [
                    BoxShadow(
                      color: headerColor.withValues(alpha: 0.20),
                      blurRadius: 16,
                      spreadRadius: 0.5,
                    )
                  ]
                : AppTheme.shadowSm,
            border: Border.all(
              color: _hovering
                  ? headerColor
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : (_isUnassigned ? AppTheme.warning.withValues(alpha: 0.25) : const Color(0xFFE2E8F0))),
              width: _hovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.sp3),
                child: Row(
                  children: [
                    AppIconCircle(
                      icon: _isUnassigned ? Icons.inbox_outlined : Icons.warehouse_outlined,
                      color: headerColor,
                      size: 28,
                      iconSize: 15,
                      hasGlow: widget.isDark,
                    ),
                    const SizedBox(width: AppTheme.sp2),
                    Expanded(
                      child: Text(
                        widget.parc.name,
                        style: AppTextStyles.bodyLg(color: widget.isDark ? Colors.white : AppTheme.ink900),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp2, vertical: 2),
                      decoration: BoxDecoration(
                        color: headerColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '${widget.parc.cars.length}',
                        style: AppTextStyles.dataSm(color: headerColor),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.parc.location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: AppTheme.sp3, bottom: AppTheme.sp2),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: widget.isDark ? Colors.white54 : AppTheme.ink600, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        widget.parc.location,
                        style: AppTextStyles.caption(color: widget.isDark ? Colors.white54 : AppTheme.ink600),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: widget.parc.cars.isEmpty
                    ? Center(
                        child: Text(
                          _hovering ? 'Déposer ici' : 'Vide',
                          style: AppTextStyles.bodyMd(color: widget.isDark ? Colors.white38 : AppTheme.ink400),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(AppTheme.sp2, 0, AppTheme.sp2, AppTheme.sp2),
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.parc.cars.length,
                        itemBuilder: (context, i) {
                          final car = widget.parc.cars[i];
                          return _DraggableCarTile(car: car, parcId: widget.parc.id, isDark: widget.isDark);
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
  final bool isDark;

  const _DraggableCarTile({required this.car, required this.parcId, required this.isDark});

  bool get _isLockedInUnassigned => parcId == 'unassigned' && car.status == 'loue';

  void _showLockedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        title: Text('Voiture louée', style: AppTextStyles.displayMd(color: isDark ? Colors.white : AppTheme.ink900)),
        content: Text(
          'Cette voiture est louée : elle reste dans « À assigner » jusqu\'à son retour.',
          style: AppTextStyles.bodyMd(color: isDark ? Colors.white70 : AppTheme.ink600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: AppTextStyles.bodyLg(color: isDark ? AppTheme.neonViolet : AppTheme.primary600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLockedInUnassigned) {
      return GestureDetector(
        onLongPress: () => _showLockedMessage(context),
        child: _CarTile(car: car, locked: true, isDark: isDark),
      );
    }

    return LongPressDraggable<_DragPayload>(
      data: _DragPayload(car, parcId),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 250, child: _CarTile(car: car, elevated: true, isDark: isDark)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _CarTile(car: car, isDark: isDark)),
      child: _CarTile(car: car, isDark: isDark),
    );
  }
}

class _CarTile extends StatelessWidget {
  final ParcCar car;
  final bool elevated;
  final bool locked;
  final bool isDark;

  const _CarTile({required this.car, this.elevated = false, this.locked = false, required this.isDark});

  Color get _statusColor {
    switch (car.status) {
      case 'disponible':
        return isDark ? AppTheme.neonMint : AppTheme.success;
      case 'loue':
        return isDark ? AppTheme.neonViolet : AppTheme.primary600;
      case 'maintenance':
        return AppTheme.danger;
      default:
        return isDark ? Colors.white60 : AppTheme.ink600;
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
      margin: const EdgeInsets.only(bottom: AppTheme.sp2),
      padding: const EdgeInsets.all(AppTheme.sp3),
      decoration: BoxDecoration(
        color: isDark
            ? (locked ? const Color(0xFF181236) : const Color(0xFF1E1642))
            : (locked ? const Color(0xFFF3F4F6) : AppTheme.surface0),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
        boxShadow: elevated
            ? [BoxShadow(color: AppTheme.neonViolet.withValues(alpha: 0.4), blurRadius: 20)]
            : (isDark ? null : AppTheme.shadowSm),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Container(
              width: 44,
              height: 44,
              color: isDark ? const Color(0xFF2A205E) : AppTheme.surfaceApp,
              child: car.imageUrl != null
                  ? Image.network(car.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.directions_car_outlined, color: isDark ? AppTheme.neonViolet : AppTheme.ink400, size: 22),
            ),
          ),
          const SizedBox(width: AppTheme.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: AppTextStyles.bodyLg(color: isDark ? Colors.white : AppTheme.ink900),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    car.plateNumber,
                    style: AppTextStyles.dataSm(color: isDark ? Colors.white70 : AppTheme.ink600),
                  ),
                ),
                const SizedBox(height: AppTheme.sp1),
                AppStatusBadge(
                  label: _statusLabel,
                  color: _statusColor,
                  glow: isDark,
                  showBorder: false,
                ),
              ],
            ),
          ),
          Icon(
            locked ? Icons.lock_outline : Icons.drag_indicator,
            color: isDark ? Colors.white38 : AppTheme.ink400,
            size: 18,
          ),
        ],
      ),
    );
  }
}