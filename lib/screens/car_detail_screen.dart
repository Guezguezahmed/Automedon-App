import 'package:flutter/material.dart';
import '../theme.dart';

/// Écran détail voiture -- design v2 (tuiles d'infos + alertes documents).
///
/// Champs volontairement absents par rapport à une maquette de référence :
/// - "Carburant" : n'existe pas dans GET /mobile-cars (§4.3 du doc API).
/// - "Documents" complet (carte grise/assurance avec statut permanent) :
///   l'API ne fournit PAS l'état de chaque document par voiture, seulement
///   des alertes d'expiration proche via GET /mobile-notifications (§4.6).
///   Cette section est donc remplacée par "Alertes documents", qui filtre
///   le flux de notifications par nom de voiture (ref.car) -- solution
///   fragile en attendant un vrai champ car_id sur les notifications,
///   mais qui n'invente aucune donnée.
class CarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> car;

  /// Notifications déjà récupérées ailleurs (ex. via notificationsProvider),
  /// pas encore filtrées par voiture -- le filtrage se fait dans ce widget.
  final List<Map<String, dynamic>> allNotifications;

  const CarDetailScreen({
    super.key,
    required this.car,
    this.allNotifications = const [],
  });

  @override
  Widget build(BuildContext context) {
    final brand = car['brand'] ?? '';
    final model = car['model'] ?? '';
    final plate = car['plate_number'] ?? '';
    final year = car['first_registration_year'] ?? '';
    final mileage = car['mileage'] ?? '';
    final transmission = car['transmission'] as String?;
    final status = car['status'] as String? ?? 'disponible';
    final activeReservation = car['active_reservation'] as Map<String, dynamic>?;

    // Filtrage fragile par nom -- cf. note en tête de fichier.
    final displayName = '$brand $model';
    final carAlerts = allNotifications.where((n) {
      final ref = n['ref'] as Map<String, dynamic>?;
      return ref != null && ref['car'] == displayName;
    }).toList();

    Color statusColor;
    String statusText;
    if (status == 'loue') {
      statusColor = AppTheme.warning;
      statusText = 'Loué';
    } else if (status == 'maintenance') {
      statusColor = AppTheme.error;
      statusText = 'Maintenance';
    } else {
      statusColor = AppTheme.success;
      statusText = 'Disponible';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // automaticallyImplyLeading (true par défaut) affiche la flèche
        // retour ET la connecte nativement à Navigator.pop() -- plus
        // fiable qu'un IconButton fait main dans un Stack/Positioned.
        iconTheme: const IconThemeData(color: AppTheme.textSecondary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // TODO: naviguer vers ReservationsScreen. Pas de filtre par
              // voiture possible pour l'instant (pas de car_id sur
              // GET /mobile-reservations) -- ouvre la liste complète.
              onPressed: () {},
              child: const Text('Voir les réservations'),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
        SizedBox(
        height: 230,
        child: Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.directions_car, size: 90, color: Colors.grey),
          ),
        ),
      ),
      Expanded(
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 4),
                          Text('$plate · $year',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                        child: const Icon(Icons.more_horiz, size: 18, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      _InfoTile(icon: Icons.speed_outlined, label: 'Kilométrage', value: '$mileage km'),
                      _InfoTile(
                        icon: Icons.settings_outlined,
                        label: 'Transmission',
                        value: transmission == 'manual' ? 'Manuelle' : 'Automatique',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoTile(icon: Icons.calendar_today_outlined, label: 'Mise en circulation', value: '$year'),
                  if (activeReservation != null) ...[
                    const SizedBox(height: 14),
                    _ContractTile(reservation: activeReservation),
                  ],
                  const SizedBox(height: 20),
                  const Text('Alertes documents',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 10),
                  if (carAlerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: AppTheme.success),
                          SizedBox(width: 8),
                          Text('Aucune alerte pour ce véhicule',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ...carAlerts.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AlertTile(notification: n),
                    )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.primary),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

/// Tuile tapable pour la réservation en cours -- rappel : active_reservation
/// (§4.3) ne contient pas d'id de réservation exploitable pour naviguer
/// vers le détail complet via GET /mobile-reservations?id=. Le onTap est
/// donc laissé vide pour l'instant, à connecter une fois ce gap résolu
/// côté backend (ou si contract_number peut servir de clé de recherche).
class _ContractTile extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const _ContractTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final clientName = reservation['client_name'] ?? '';
    final endDate = _formatDate(reservation['end_date'] as String?);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contrat en cours', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 3),
                  Text('$clientName · jusqu\'au $endDate',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _AlertTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final ref = notification['ref'] as Map<String, dynamic>?;
    final paper = ref?['paper'] ?? notification['title'] ?? '';
    final daysLeft = notification['daysLeft'] as int? ?? 0;
    final severity = notification['severity'] as String? ?? 'info';

    final isDanger = severity == 'danger' || daysLeft < 0;
    final bg = isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED);
    final badgeBg = isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final fg = isDanger ? AppTheme.error : const Color(0xFFB45309);
    final label = daysLeft < 0 ? 'En retard de ${-daysLeft}j' : 'Expire dans ${daysLeft}j';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(paper, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String? isoDate) {
  if (isoDate == null) return '--';
  try {
    final date = DateTime.parse(isoDate);
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${date.day} ${months[date.month - 1]}';
  } catch (_) {
    return isoDate;
  }
}