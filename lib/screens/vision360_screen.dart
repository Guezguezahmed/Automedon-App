import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// ---------------------------------------------------------------------
/// Vision360 -- connecté à vision360Provider (au lieu de données mockées).
/// La conversion se fait dans _mapToVehicles() : elle combine cars[] +
/// timeline[] du Vision360Response pour reconstituer les _MockVehicle
/// attendus par les widgets existants (_VehicleStatusCard,
/// _VehicleTimelineCard).
///
/// Correctifs appliqués (voir conversation) :
/// 1) Le toggle "Réservations à venir uniquement" filtre maintenant
///    réellement la liste affichée (avant : ne changeait que la bannière).
/// 2) Le statut 'maintenance' (3e valeur possible selon MOBILE_API.md,
///    section 4.3) est géré explicitement au lieu d'être confondu avec
///    'disponible'.
/// 3) occupiedDayIndex (toujours 0) est remplacé par un couple
///    (occupiedStartIndex, occupiedSpan) calculé à partir de la vraie
///    date de début/fin de la réservation par rapport à window.start,
///    pour positionner correctement le highlight dans la mini-timeline
///    de 7 jours et représenter sa durée réelle (pas juste 1 case).
///
/// À CONFIRMER côté backend/design (pas dans MOBILE_API.md) :
/// - Le sens exact du filtre "Tous / Auto / Manuel" vu sur le web (a
///   priori PAS la transmission de la voiture -- plutôt un mode de
///   création de réservation). Pas encore implémenté ici tant que ce
///   n'est pas confirmé.
/// - Le comportement exact voulu pour "Réservations à venir uniquement" :
///   ici interprété comme "n'afficher que les véhicules ayant une
///   réservation (en cours ou à venir)", à ajuster si le vrai
///   comportement est différent (ex: exclure aussi les réservations déjà
///   en cours, ne garder que le futur strict).
/// ---------------------------------------------------------------------
class Vision360Screen extends ConsumerStatefulWidget {
  const Vision360Screen({super.key});

  @override
  ConsumerState<Vision360Screen> createState() => _Vision360ScreenState();
}

enum _ViewMode { liste, chronologie }

const Color _kWarning = Color(0xFFF59E0B);

// Nombre de colonnes de la mini-timeline (indépendant de `window.days`,
// qui peut valoir jusqu'à 60 -- on affiche ici une fenêtre glissante de
// 7 jours à partir de window.start pour rester lisible sur mobile).
const int _kTimelineColumns = 7;

class _Vision360ScreenState extends ConsumerState<Vision360Screen> {
  bool _showUpcomingOnly = true;
  _ViewMode _mode = _ViewMode.liste;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vision360Async = ref.watch(vision360Provider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        title: Text(
          'Vision360',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : AppTheme.ink900,
          ),
        ),
        centerTitle: false,
      ),
      body: vision360Async.when(
        data: (data) => _buildBody(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Erreur de chargement : $e')),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    final allVehicles = _mapToVehicles(data);
    final carCount = (data['cars'] as List? ?? []).length;
    final returningSoon = (data['returningSoon'] as List? ?? []);

    // Correctif (1) : le toggle filtre réellement la liste affichée --
    // on ne garde que les véhicules ayant une réservation (loués ou en
    // maintenance planifiée avec un client rattaché) quand actif.
    final vehicles = _showUpcomingOnly
        ? allVehicles.where((v) => v.clientName != null).toList()
        : allVehicles;

    return Column(
      children: [
        _buildHeaderCard(carCount),
        _buildToggleCard(),
        if (_showUpcomingOnly) _buildUpcomingBanner(returningSoon.length),
        const SizedBox(height: 4),
        _buildModeSwitch(),
        Expanded(
          child: vehicles.isEmpty
              ? _buildEmptyState()
              : (_mode == _ViewMode.liste
              ? _buildListView(vehicles)
              : _buildTimelineView(vehicles, data['window'] as Map<String, dynamic>?)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy_outlined, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text(
              'Aucune réservation à venir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Désactivez le filtre pour voir tous les véhicules.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Conversion des données réelles (Vision360Response en Map) vers le
  // modèle d'affichage _MockVehicle utilisé par les widgets existants.
  // ------------------------------------------------------------------
  List<_MockVehicle> _mapToVehicles(Map<String, dynamic> data) {
    final cars = (data['cars'] as List? ?? []).cast<Map<String, dynamic>>();
    final timeline = (data['timeline'] as List? ?? []).cast<Map<String, dynamic>>();

    DateTime? windowStart;
    final windowRaw = data['window'] as Map<String, dynamic>?;
    if (windowRaw != null && windowRaw['start'] != null) {
      try {
        windowStart = DateTime.parse(windowRaw['start'] as String);
      } catch (_) {}
    }

    return cars.map((c) {
      // Correctif (2) : statut à 3 valeurs (disponible | loue | maintenance)
      // au lieu d'un simple bool isRented qui confondait maintenance et
      // disponible.
      final status = (c['status'] as String?) ?? 'disponible';
      final isRented = status == 'loue';
      final activeReservation = c['active_reservation'] as Map<String, dynamic>?;

      // Cherche l'entrée timeline correspondante et active pour le
      // libellé "Retour Demain" -- à défaut, se rabat sur
      // active_reservation de la voiture.
      final timelineEntry = timeline.cast<Map<String, dynamic>?>().firstWhere(
            (t) => t?['car_id'] == c['id'] && (t?['status'] == 'active' || t?['status'] == null),
        orElse: () => null,
      );

      String? paymentLabel;
      if (activeReservation != null) {
        final total = (activeReservation['total_price'] as num?) ?? 0;
        final advance = (activeReservation['advance_payment'] as num?) ?? 0;
        final remaining = total - advance;
        if (remaining > 0) paymentLabel = 'Reste ${remaining.toStringAsFixed(2)} DT';
      }

      final startDateStr = timelineEntry?['start_date'] ?? activeReservation?['start_date'];
      final endDateStr = timelineEntry?['end_date'] ?? activeReservation?['end_date'];

      // Correctif (3) : position + durée réelles dans la mini-timeline,
      // au lieu d'un occupiedDayIndex toujours égal à 0.
      int? occupiedStartIndex;
      int occupiedSpan = 1;
      if (isRented && windowStart != null && startDateStr != null) {
        final computed = _computeTimelineSpan(
          windowStart: windowStart,
          startIso: startDateStr as String,
          endIso: endDateStr as String?,
        );
        occupiedStartIndex = computed.$1;
        occupiedSpan = computed.$2;
      }

      return _MockVehicle(
        brand: c['brand'] ?? '',
        model: c['model'] ?? '',
        plate: c['plate_number'] ?? '',
        status: status,
        clientName: timelineEntry?['client_name'] ?? activeReservation?['client_name'],
        startDate: _formatDateTime(startDateStr),
        endDate: _formatDateTime(endDateStr),
        paymentLabel: paymentLabel,
        statusLabel: isRented ? _daysLeftLabel(endDateStr as String?) : null,
        occupiedStartIndex: occupiedStartIndex,
        occupiedSpan: occupiedSpan,
      );
    }).toList();
  }

  /// Calcule (index de la case de départ, nombre de cases occupées) dans
  /// une mini-timeline de `_kTimelineColumns` jours démarrant à
  /// `windowStart`. Résultat borné à la fenêtre visible : une réservation
  /// commencée avant `windowStart` démarre à l'index 0 avec un span
  /// réduit d'autant ; une réservation qui dépasse le bord droit est
  /// tronquée à la dernière colonne.
  (int?, int) _computeTimelineSpan({
    required DateTime windowStart,
    required String startIso,
    String? endIso,
  }) {
    try {
      final winStartDay = DateTime(windowStart.year, windowStart.month, windowStart.day);
      final start = DateTime.parse(startIso);
      final startDay = DateTime(start.year, start.month, start.day);

      int startIdx = startDay.difference(winStartDay).inDays;
      int span = 1;

      if (endIso != null) {
        final end = DateTime.parse(endIso);
        final endDay = DateTime(end.year, end.month, end.day);
        span = endDay.difference(startDay).inDays + 1;
        if (span < 1) span = 1;
      }

      // Réservation déjà commencée avant le début de la fenêtre : on
      // recadre le départ sur la 1ère colonne et on réduit la durée
      // affichée d'autant, plutôt que de la faire démarrer hors-cadre.
      if (startIdx < 0) {
        span += startIdx; // startIdx est négatif ici
        startIdx = 0;
      }

      // Réservation qui commence après la fenêtre visible de 7 jours :
      // rien à afficher dans cette mini-vue.
      if (startIdx >= _kTimelineColumns || span <= 0) {
        return (null, 0);
      }

      if (startIdx + span > _kTimelineColumns) {
        span = _kTimelineColumns - startIdx;
      }

      return (startIdx, span);
    } catch (_) {
      return (null, 0);
    }
  }

  String? _formatDateTime(String? iso) {
    if (iso == null) return null;
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String? _daysLeftLabel(String? endIso) {
    if (endIso == null) return null;
    try {
      final end = DateTime.parse(endIso);
      final days = end.difference(DateTime.now()).inDays;
      if (days < 0) return 'En retard';
      if (days == 0) return 'Retour Aujourd\'hui';
      if (days == 1) return 'Retour Demain';
      return 'Retour dans ${days}j';
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------------
  // Header : icône Vision360 + compteur flotte (dynamique)
  // ------------------------------------------------------------------
  Widget _buildHeaderCard(int carCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.blur_circular, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vision360',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$carCount véhicules dans la flotte',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Réservations à venir uniquement',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          Switch(
            value: _showUpcomingOnly,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _showUpcomingOnly = v),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3F0FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.event_available, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Réservations confirmées à venir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$count réservation${count > 1 ? 's' : ''} confirmée${count > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
        child: Row(
          children: [
            Expanded(child: _segmentButton('Liste', Icons.list_alt_outlined, _ViewMode.liste)),
            Expanded(child: _segmentButton('Chronologie', Icons.calendar_month_outlined, _ViewMode.chronologie)),
          ],
        ),
      ),
    );
  }

  Widget _segmentButton(String label, IconData icon, _ViewMode value) {
    final selected = _mode == value;
    return GestureDetector(
      onTap: () => setState(() => _mode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.textSecondary,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<_MockVehicle> vehicles) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: vehicles.map((v) => _VehicleStatusCard(vehicle: v)).toList(),
    );
  }

  Widget _buildTimelineView(List<_MockVehicle> vehicles, Map<String, dynamic>? window) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _buildDateRangeBar(window),
        const SizedBox(height: 12),
        ...vehicles.map((v) => _VehicleTimelineCard(vehicle: v)),
      ],
    );
  }

  Widget _buildDateRangeBar(Map<String, dynamic>? window) {
    String label = '--';
    if (window != null) {
      try {
        final start = DateTime.parse(window['start'] as String);
        final end = DateTime.parse(window['end'] as String);
        const months = ['Jan.', 'Fév.', 'Mar.', 'Avr.', 'Mai', 'Juin', 'Juil.', 'Août', 'Sep.', 'Oct.', 'Nov.', 'Déc.'];
        label = '${start.day} ${months[start.month - 1]} — ${end.day} ${months[end.month - 1]} ${end.year}';
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, size: 18, color: AppTheme.textSecondary),
          const Spacer(),
          const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

// =======================================================================
// Modèle d'affichage -- alimenté par _mapToVehicles() depuis les vraies
// données.
// =======================================================================

class _MockVehicle {
  final String brand;
  final String model;
  final String plate;
  final String status; // 'disponible' | 'loue' | 'maintenance'
  final String? clientName;
  final String? startDate;
  final String? endDate;
  final String? paymentLabel;
  final String? statusLabel;
  final int? occupiedStartIndex;
  final int occupiedSpan;

  const _MockVehicle({
    required this.brand,
    required this.model,
    required this.plate,
    required this.status,
    this.clientName,
    this.startDate,
    this.endDate,
    this.paymentLabel,
    this.statusLabel,
    this.occupiedStartIndex,
    this.occupiedSpan = 1,
  });
}

/// Centralise le libellé + la couleur associés à chaque statut de
/// voiture, pour rester cohérent entre la carte liste et la mini-timeline
/// (et éviter que 'maintenance' soit traité comme 'disponible').
class _StatusStyle {
  final String label;
  final Color color;
  const _StatusStyle(this.label, this.color);

  static _StatusStyle of(String status) {
    switch (status) {
      case 'loue':
        return const _StatusStyle('Loué', _kWarning);
      case 'maintenance':
        return const _StatusStyle('Maintenance', AppTheme.error);
      case 'disponible':
      default:
        return const _StatusStyle('Disponible', AppTheme.success);
    }
  }
}

class _VehicleStatusCard extends StatelessWidget {
  final _MockVehicle vehicle;
  const _VehicleStatusCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isRented = vehicle.status == 'loue';
    final style = _StatusStyle.of(vehicle.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_car_filled_outlined, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${vehicle.brand} ${vehicle.model}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(vehicle.plate,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusPill(style.label, filled: true, color: style.color),
            ],
          ),
          if (isRented) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(vehicle.clientName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      if (vehicle.statusLabel != null) ...[
                        const SizedBox(width: 6),
                        _statusPill(vehicle.statusLabel!, filled: false, color: _kWarning),
                      ],
                    ],
                  ),
                  if (vehicle.paymentLabel != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(999)),
                        child: Text(vehicle.paymentLabel!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.error)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _dateChip(Icons.login, 'Départ', vehicle.startDate ?? '--'),
                      const SizedBox(width: 8),
                      _dateChip(Icons.logout, 'Retour', vehicle.endDate ?? '--'),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (vehicle.status == 'maintenance') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: const [
                  Icon(Icons.build_outlined, size: 14, color: AppTheme.error),
                  SizedBox(width: 6),
                  Text('Immobilisée pour maintenance aujourd\'hui',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.error)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateChip(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Expanded(
            child: Text('$label: $value',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, {required bool filled, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: filled ? Colors.white : color),
      ),
    );
  }
}

class _VehicleTimelineCard extends StatelessWidget {
  final _MockVehicle vehicle;
  const _VehicleTimelineCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final style = _StatusStyle.of(vehicle.status);
    final hasOccupiedRange = vehicle.occupiedStartIndex != null && vehicle.occupiedSpan > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${vehicle.brand} ${vehicle.model}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 8),
              Text(vehicle.plate, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_kTimelineColumns, (i) {
              final active = hasOccupiedRange &&
                  i >= vehicle.occupiedStartIndex! &&
                  i < vehicle.occupiedStartIndex! + vehicle.occupiedSpan;
              // On affiche le nom du client seulement sur la case du
              // milieu de la plage occupée, pour éviter de le répéter
              // sur chaque jour loué.
              final isLabelCell = active &&
                  i == vehicle.occupiedStartIndex! + (vehicle.occupiedSpan ~/ 2);

              return Expanded(
                child: Container(
                  height: 28,
                  margin: EdgeInsets.only(right: i == _kTimelineColumns - 1 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: active ? style.color : AppTheme.success.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: isLabelCell
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      vehicle.clientName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}