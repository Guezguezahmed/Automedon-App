import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/reservation.dart';
import '../theme.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(reservationDetailProvider(reservationId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Détail du contrat'),
      ),
      body: detailAsync.when(
        data: (data) {
          final reservation = Reservation.fromJson(data['reservation'] as Map<String, dynamic>);
          return _buildContent(context, reservation);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(
          child: Text('Erreur: $e', style: const TextStyle(color: AppTheme.error)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Reservation r) {
    final statusInfo = _statusInfo(r.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Client + statut
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.clientName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CONTRAT ${r.contractNumber ?? r.reservationNumber ?? "N/A"}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo.badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusInfo.label,
                        style: TextStyle(
                          color: statusInfo.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.clientPhone != null) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        r.clientPhone!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Période de location
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Période de location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _dateBlock(context, 'Départ', r.startDate),
                    ),
                    Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                    Expanded(
                      child: _dateBlock(context, 'Retour', r.endDate, alignRight: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Véhicule
        if (r.car != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 50,
                      color: AppTheme.primaryLight.withOpacity(0.15),
                      child: r.car!.imageUrl != null
                          ? Image.network(
                        r.car!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.directions_car, color: AppTheme.primary),
                      )
                          : const Icon(Icons.directions_car, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.car!.brand} ${r.car!.model}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                        ),
                        if (r.car!.licensePlate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            r.car!.licensePlate!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (r.car != null) const SizedBox(height: 20),

        // Détails financiers
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 16),
                _row(context, 'Prix total', '${r.totalPrice ?? 0} DT', isTotal: true),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 12),
                _row(context, 'Avance versée', '${r.advancePayment ?? 0} DT'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateBlock(BuildContext context, String label, String isoDate, {bool alignRight = false}) {
    final formatted = _formatDate(isoDate);
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const mois = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${date.day} ${mois[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _row(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'completed':
        return _StatusInfo(
          label: 'Terminée',
          badgeColor: AppTheme.success.withOpacity(0.15),
          textColor: AppTheme.success,
        );
      case 'cancelled':
        return _StatusInfo(
          label: 'Annulée',
          badgeColor: AppTheme.error.withOpacity(0.15),
          textColor: AppTheme.error,
        );
      case 'confirmed':
        return _StatusInfo(
          label: 'Prévue',
          badgeColor: AppTheme.warning.withOpacity(0.15),
          textColor: AppTheme.warning,
        );
      case 'active':
      default:
        return _StatusInfo(
          label: 'En cours',
          badgeColor: AppTheme.primary.withOpacity(0.15),
          textColor: AppTheme.primary,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color badgeColor;
  final Color textColor;

  _StatusInfo({required this.label, required this.badgeColor, required this.textColor});
}