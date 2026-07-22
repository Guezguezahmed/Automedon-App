import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';
import 'partenaires_screen.dart';

class LeasingScreen extends StatelessWidget {
  const LeasingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('FINANCE', style: AppTextStyles.caption(color: isDark ? AppTheme.neonMint : AppTheme.success).copyWith(fontWeight: FontWeight.bold)),
            Text('Leasing', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
            Text('Gérez vos contrats de leasing', style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600)),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PartenairesScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            child: Text('Partenaire', style: AppTextStyles.bodyLg(color: AppTheme.ink900)),
          ),
          const SizedBox(width: AppTheme.sp2),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink900,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Nouveau', style: AppTextStyles.bodyLg(color: Colors.white)),
          ),
          const SizedBox(width: AppTheme.sp4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.sp4),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('CONTRATS', '0', 'voitures')),
                const SizedBox(width: AppTheme.sp3),
                Expanded(child: _buildStatCard('FINANCÉ', '0,000', 'DT')),
              ],
            ),
            const SizedBox(height: AppTheme.sp3),
            Row(
              children: [
                Expanded(child: _buildStatCard('PAYÉ', '0,000', 'DT')),
                const SizedBox(width: AppTheme.sp3),
                Expanded(child: _buildStatCard('RESTANT', '0', 'échéances')),
              ],
            ),
            const SizedBox(height: AppTheme.sp8),
            AppEmptyState(
              icon: Icons.description_outlined,
              title: 'Aucun contrat leasing',
              description: 'Vous n\'avez pas encore ajouté de contrat de leasing à votre flotte.',
              actionLabel: 'Nouveau Contrat',
              onAction: () {},
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp4),
      shadows: AppTheme.shadowSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption(color: AppTheme.ink600)),
          const SizedBox(height: AppTheme.sp2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTextStyles.dataLg(color: AppTheme.ink900)),
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.caption(color: AppTheme.ink600)),
            ],
          )
        ],
      ),
    );
  }
}
