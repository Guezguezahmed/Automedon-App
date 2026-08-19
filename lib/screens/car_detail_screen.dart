import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/kit.dart';

/// Écran détail voiture -- design v5 (hero photo studio + tuiles stat à
/// badges lumineux + bouton dégradé, cohérent en light et dark mode).
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
///
/// La photo du véhicule (`image_url`) vient du backend (GET /mobile-cars).
/// Si absente ou en échec de chargement, on retombe sur une icône.
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
    final imageUrl = car['image_url'] as String?;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkSurface : Colors.white;
    final tileBg = isDark ? AppTheme.darkBg : const Color(0xFFF9FAFB);
    final tileBorder = isDark ? AppTheme.darkBorder : const Color(0xFFF0F1F3);
    final primaryText = isDark ? Colors.white : AppTheme.ink900;
    final secondaryText = isDark ? Colors.white60 : AppTheme.ink600;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // La zone photo est toujours sombre -> icônes toujours blanches.
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 0.5),
                  ],
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
          decoration: BoxDecoration(
            color: sheetBg,
            border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB))),
          ),
          child: AppPrimaryButton(
            label: 'Voir les réservations',
            icon: Icons.calendar_month_outlined,
            // TODO: naviguer vers ReservationsScreen. Pas de filtre par
            // voiture possible pour l'instant (pas de car_id sur
            // GET /mobile-reservations) -- ouvre la liste complète.
            onPressed: () {},
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Hero photo studio (toujours sombre, quel que soit le thème) ──
          SizedBox(
            height: 300,
            child: Container(
              width: double.infinity,
              color: AppTheme.darkBg,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Halo violet ambiant, plus large et plus doux pour donner
                  // du volume à la scène.
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: 320,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.neonViolet.withValues(alpha: 0.4),
                            AppTheme.neonBlue.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Anneau "pedestal" sous la voiture
                  Positioned(
                    bottom: 46,
                    child: Container(
                      width: 210,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.neonViolet.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: AppTheme.neonViolet.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
                    child: _CarHeroImage(imageUrl: imageUrl),
                  ),
                  // Voile en dégradé en haut pour garder l'AppBar lisible
                  // par-dessus n'importe quelle photo.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.only(
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
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText)),
                              const SizedBox(height: 4),
                              Text('$plate · $year', style: TextStyle(fontSize: 13, color: secondaryText)),
                            ],
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: tileBg, shape: BoxShape.circle),
                            child: Icon(Icons.more_horiz, size: 18, color: secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Grille 2x2 de tuiles stat, à badges d'icônes lumineux
                      // (cohérente en light et dark mode).
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.55,
                        children: [
                          _StatTile(
                            icon: Icons.speed_outlined,
                            iconColor: AppTheme.warning,
                            label: 'Kilométrage',
                            value: '$mileage',
                            unit: 'km',
                            tileBg: tileBg,
                            tileBorder: tileBorder,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                          _StatTile(
                            icon: Icons.directions_car_filled_outlined,
                            iconColor: AppTheme.info,
                            label: 'Mise en circulation',
                            value: year.toString().isEmpty ? '--' : '$year',
                            tileBg: tileBg,
                            tileBorder: tileBorder,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                          _StatTile(
                            icon: Icons.settings_outlined,
                            iconColor: AppTheme.neonViolet,
                            label: 'Transmission',
                            value: transmission == 'manual' ? 'Manuelle' : 'Automatique',
                            tileBg: tileBg,
                            tileBorder: tileBorder,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                          _StatTile(
                            icon: Icons.circle,
                            iconColor: statusColor,
                            iconSize: 10,
                            label: 'Statut',
                            value: statusText,
                            valueColor: statusColor,
                            tileBg: tileBg,
                            tileBorder: tileBorder,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                        ],
                      ),

                      if (activeReservation != null) ...[
                        const SizedBox(height: 14),
                        _ContractTile(
                          reservation: activeReservation,
                          tileBg: tileBg,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('Alertes documents',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primaryText)),
                      const SizedBox(height: 10),
                      if (carAlerts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tileBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tileBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.success),
                              const SizedBox(width: 8),
                              Text('Aucune alerte pour ce véhicule',
                                  style: TextStyle(fontSize: 13, color: secondaryText)),
                            ],
                          ),
                        )
                      else
                        ...carAlerts.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AlertTile(notification: n),
                        )),
                      const SizedBox(height: 28),
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

/// Image du véhicule provenant du backend (`car['image_url']`).
/// Fallback sur une icône si l'URL est absente ou si le chargement échoue.
class _CarHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _CarHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.directions_car, size: 90, color: Colors.white24);
    }

    return SizedBox(
      width: double.infinity,
      height: 220,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonViolet),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.directions_car, size: 90, color: Colors.white24);
        },
      ),
    );
  }
}

/// Tuile stat unifiée : badge d'icône circulaire lumineux + libellé sur une
/// ligne, puis valeur en gras -- inspirée de la maquette de référence.
/// Utilisée pour Kilométrage / Mise en circulation / Transmission / Statut,
/// cohérente en light comme en dark mode.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;
  final Color tileBg;
  final Color tileBorder;
  final Color primaryText;
  final Color secondaryText;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    this.iconSize = 15,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    required this.tileBg,
    required this.tileBorder,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tileBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              AppIconCircle(
                icon: icon,
                color: iconColor,
                size: 26,
                iconSize: iconSize,
                hasGlow: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: secondaryText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? primaryText,
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(unit!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryText)),
              ],
            ],
          ),
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
  final Color tileBg;
  final Color primaryText;
  final Color secondaryText;

  const _ContractTile({
    required this.reservation,
    required this.tileBg,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final clientName = reservation['client_name'] ?? '';
    final endDate = _formatDate(reservation['end_date'] as String?);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const AppIconCircle(
              icon: Icons.person_outline,
              color: AppTheme.neonViolet,
              size: 34,
              iconSize: 18,
              hasGlow: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contrat en cours', style: TextStyle(fontSize: 11, color: secondaryText)),
                  const SizedBox(height: 3),
                  Text(clientName.toString(),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryText)),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: secondaryText),
                const SizedBox(width: 4),
                Text('jusqu\'au $endDate', style: TextStyle(fontSize: 12, color: secondaryText)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 18, color: secondaryText),
              ],
            ),
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

    // Ces alertes gardent des teintes claires fixes (rouge/orange pâle) --
    // ce sont des badges d'alerte, cohérents dans les deux thèmes, à
    // l'image des autres badges de statut de l'app.
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
              Text(paper, style: const TextStyle(fontSize: 13, color: AppTheme.ink900)),
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