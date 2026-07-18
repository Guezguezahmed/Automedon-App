import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tenant.dart';
import '../providers/providers.dart';
import '../theme.dart'; // adapter le chemin vers votre AppTheme

/// Traduit le statut brut du Tenant ("active", "suspended", ...) en libellé
/// affiché à l'utilisateur. Utilisé à la fois par le badge du header et
/// par la carte "Informations" pour rester cohérent.
String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'Actif';
    case 'suspended':
      return 'Suspendu';
    default:
      return status;
  }
}

/// Écran "Mon agence" — affiche les infos du Tenant courant
/// (issu de GET /mobile-me via `meProvider`).
/// Les compteurs (véhicules / contrats / clients) sont dérivés de
/// `carsProvider` et `reservationsProvider` : ce ne sont pas des champs
/// du modèle Tenant, mais des agrégats calculés côté app.
class MonAgenceScreen extends ConsumerWidget {
  const MonAgenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon agence')),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(meProvider),
        ),
        data: (data) {
          final tenant = Tenant.fromJson(data['tenant'] as Map<String, dynamic>);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(meProvider);
              ref.invalidate(carsProvider(null));
              ref.invalidate(reservationsProvider(const ReservationsParams()));
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AgencyHeader(tenant: tenant),
                const SizedBox(height: 16),
                const _StatsRow(),
                const SizedBox(height: 16),
                _InfoCard(tenant: tenant),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bandeau violet en haut : logo/initiales, nom, slug, badge de statut.
class _AgencyHeader extends StatelessWidget {
  final Tenant tenant;
  const _AgencyHeader({required this.tenant});

  String get _initials {
    final parts = tenant.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  bool get _isActive => tenant.status.toLowerCase() == 'active';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
              image: tenant.logoUrl != null
                  ? DecorationImage(
                image: NetworkImage(tenant.logoUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            alignment: Alignment.center,
            child: tenant.logoUrl == null
                ? Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            tenant.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tenant.slug,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _isActive ? AppTheme.success : AppTheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel(tenant.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rangée de 3 compteurs (véhicules / contrats / clients).
class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider(null));
    final reservationsAsync = ref.watch(reservationsProvider(const ReservationsParams()));

    if (carsAsync.isLoading || reservationsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _StatsRowSkeleton(),
      );
    }

    if (carsAsync.hasError || reservationsAsync.hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _StatsRowSkeleton(),
      );
    }

    final cars = carsAsync.value?['cars'] as List? ?? [];
    final reservations = reservationsAsync.value?['reservations'] as List? ?? [];

    // Clients = nb de noms de clients distincts parmi les réservations.
    final distinctClients = reservations
        .map((r) => (r as Map<String, dynamic>)['client_name'] as String?)
        .whereType<String>()
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(value: cars.length, label: 'Véhicules'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              value: (reservationsAsync.value?['total'] as int?) ?? reservations.length,
              label: 'Contrats',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(value: distinctClients.length, label: 'Clients'),
          ),
        ],
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Carte "Informations" listant les champs du Tenant.
class _InfoCard extends StatelessWidget {
  final Tenant tenant;
  const _InfoCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Informations',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Identifiant (slug)',
                  value: tenant.slug,
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                _InfoRow(
                  icon: Icons.storefront_outlined,
                  label: "Nom de l'agence",
                  value: tenant.name,
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Statut',
                  value: _statusLabel(tenant.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}