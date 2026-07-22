import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tenant.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

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

class MonAgenceScreen extends ConsumerWidget {
  const MonAgenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meAsync = ref.watch(meProvider);

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
          title: Text('Mon agence', style: AppTextStyles.displayLg(context: context)),
        ),
        body: meAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: isDark ? AppTheme.neonViolet : AppTheme.primary600)),
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
                physics: const BouncingScrollPhysics(),
                children: [
                  _AgencyHeader(tenant: tenant, isDark: isDark),
                  const SizedBox(height: 16),
                  _StatsRow(isDark: isDark),
                  const SizedBox(height: 16),
                  _InfoCard(tenant: tenant, isDark: isDark),
                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AgencyHeader extends StatelessWidget {
  final Tenant tenant;
  final bool isDark;
  const _AgencyHeader({required this.tenant, required this.isDark});

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
      padding: const EdgeInsets.symmetric(vertical: AppTheme.sp8, horizontal: AppTheme.sp5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E1548), Color(0xFF110B2D)]
              : const [Color(0xFF5B4FE0), Color(0xFF3B2DB8), Color(0xFF23187F)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonViolet.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.sp3),
          Text(
            tenant.name,
            style: AppTextStyles.displayLg(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              tenant.slug,
              style: AppTextStyles.dataSm(color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
          const SizedBox(height: AppTheme.sp3),
          AppGlassBadge(
            label: _statusLabel(tenant.status),
            dotColor: _isActive ? (isDark ? AppTheme.neonMint : AppTheme.success) : AppTheme.danger,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

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

    final distinctClients = reservations
        .map((r) => (r as Map<String, dynamic>)['client_name'] as String?)
        .whereType<String>()
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(value: cars.length, label: 'Véhicules', isDark: isDark),
          ),
          const SizedBox(width: AppTheme.sp2),
          Expanded(
            child: _StatCard(
              value: (reservationsAsync.value?['total'] as int?) ?? reservations.length,
              label: 'Contrats',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppTheme.sp2),
          Expanded(
            child: _StatCard(value: distinctClients.length, label: 'Clients', isDark: isDark),
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
                color: Colors.white10,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
  final bool isDark;
  const _StatCard({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3),
      hasGlow: isDark,
      glowColor: isDark ? AppTheme.neonViolet : null,
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.dataLg(color: isDark ? AppTheme.neonCyan : AppTheme.primary600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption(color: isDark ? Colors.white70 : AppTheme.ink600),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Tenant tenant;
  final bool isDark;
  const _InfoCard({required this.tenant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Informations',
              style: TextStyle(color: isDark ? Colors.white60 : AppTheme.ink600, fontSize: 13),
            ),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            hasGlow: isDark,
            glowColor: isDark ? AppTheme.neonCyan : null,
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Identifiant (slug)',
                  value: tenant.slug,
                  isDark: isDark,
                ),
                Divider(height: 1, thickness: 1, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                _InfoRow(
                  icon: Icons.storefront_outlined,
                  label: "Nom de l'agence",
                  value: tenant.name,
                  isDark: isDark,
                ),
                Divider(height: 1, thickness: 1, color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Statut',
                  value: _statusLabel(tenant.status),
                  isDark: isDark,
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
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppTheme.neonViolet : AppTheme.primary600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          AppIconCircle(
            icon: icon,
            color: accent,
            size: 36,
            hasGlow: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: isDark ? Colors.white60 : AppTheme.ink600, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900, fontSize: 14, fontWeight: FontWeight.w600)),
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
            const Icon(Icons.error_outline, color: AppTheme.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(context: context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}