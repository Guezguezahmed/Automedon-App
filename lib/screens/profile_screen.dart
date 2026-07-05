import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(meAsync)),
          SliverToBoxAdapter(child: _buildStatsBar()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuItem(context, Icons.settings_outlined, 'Mon agence', 'AutoLocation Tunis', AppTheme.primary, null),
                _buildMenuItem(context, Icons.description_outlined, 'Leasing', 'Contrats de leasing', Colors.blue, '/leasing'),
                _buildMenuItem(context, Icons.directions_car_outlined, 'Gestion Flotte', 'Détails de la flotte', AppTheme.success, '/gestion_flotte'),
                _buildMenuItem(context, Icons.star_border, 'Services', 'Services additionnels', Colors.pink, '/services'),
                _buildMenuItem(context, Icons.trending_up, 'Historique', 'Historique flotte', Colors.deepPurple, '/historique'),
                _buildMenuItem(context, Icons.warning_amber_rounded, 'Signalements', 'Liste noire', AppTheme.error, '/signalements'),
                
                // Notifications switch
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none, color: AppTheme.warning),
                    ),
                    title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('Activées', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    trailing: Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: AppTheme.primary,
                    ),
                  ),
                ),

                // Language toggle
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.language, color: AppTheme.success),
                    ),
                    title: const Text('Langue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('Interface de l\'application', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                            child: const Text('FR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text('AR', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text('Déconnexion', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> meAsync) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: meAsync.when(
        data: (data) {
          final user = data['user'];
          final name = user['username'] ?? 'User';
          final initials = name.toString().substring(0, 2).toUpperCase();

          return Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  color: Colors.white.withOpacity(0.2),
                ),
                alignment: Alignment.center,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('AutoLocation Tunis • Gérant', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppTheme.success, size: 8),
                    SizedBox(width: 6),
                    Text('Premium • Actif', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => const Text('Erreur', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem('5', 'Véhicules'),
            _VerticalDivider(),
            _StatItem('47', 'Contrats'),
            _VerticalDivider(),
            _StatItem('23', 'Clients'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, Color color, String? route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (route != null) {
            context.push(route);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: const Color(0xFFE5E7EB));
  }
}
