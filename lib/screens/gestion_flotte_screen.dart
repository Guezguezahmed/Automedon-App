import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';
import 'parc_screen.dart';

class GestionFlotteScreen extends StatelessWidget {
  const GestionFlotteScreen({super.key});

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
            Text('Gestion Flotte', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
            Text('Gérez votre flotte', style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600)),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcsScreen()));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            child: Text('Parc', style: AppTextStyles.bodyLg(color: AppTheme.ink900)),
          ),
          const SizedBox(width: AppTheme.sp2),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Voiture'),
          ),
          const SizedBox(width: AppTheme.sp4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.sp4),
        children: [
          Row(
            children: [
              const AppIconCircle(
                icon: Icons.directions_car_outlined,
                color: AppTheme.ink600,
                backgroundColor: Colors.white,
                size: 36,
                iconSize: 18,
              ),
              const SizedBox(width: AppTheme.sp3),
              Expanded(child: Text('Peugeot', style: AppTextStyles.displayMd())),
              Text('2', style: AppTextStyles.dataLg(color: AppTheme.ink600).copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: AppTheme.sp4),
          AppCard(
            padding: const EdgeInsets.all(AppTheme.sp4),
            shadows: AppTheme.shadowSm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('208 Active', style: AppTextStyles.bodyLg(color: AppTheme.ink900)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceApp,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('112 TUN 4567', style: AppTextStyles.dataSm(color: AppTheme.ink600)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppStatusBadge(
                      label: 'Disponible',
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: AppTheme.sp2),
                    Row(
                      children: [
                        const Icon(Icons.description_outlined, size: 14, color: AppTheme.ink600),
                        const SizedBox(width: 4),
                        Text('4/4', style: AppTextStyles.dataSm(color: AppTheme.ink600)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
