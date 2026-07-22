import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

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
            Text('Historique Flotte', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
            Text(
              '7 véhicules · 2 réservations · 1 540,000 DT de CA',
              style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.sp4),
            child: Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(AppTheme.sp4),
                    shadows: AppTheme.shadowSm,
                    child: Row(
                      children: [
                        const AppIconCircle(
                          icon: Icons.directions_car_outlined,
                          color: AppTheme.primary600,
                          backgroundColor: Color(0x1A5B4FE0),
                          size: 40,
                          iconSize: 20,
                        ),
                        const SizedBox(width: AppTheme.sp3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voitures', style: AppTextStyles.caption(color: AppTheme.ink600)),
                            Text('7', style: AppTextStyles.dataLg(color: AppTheme.ink900)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.sp3),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(AppTheme.sp4),
                    shadows: AppTheme.shadowSm,
                    child: Row(
                      children: [
                        const AppIconCircle(
                          icon: Icons.trending_up,
                          color: AppTheme.success,
                          backgroundColor: Color(0x1A2FBE8F),
                          size: 40,
                          iconSize: 20,
                        ),
                        const SizedBox(width: AppTheme.sp3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CA Total', style: AppTextStyles.caption(color: AppTheme.ink600)),
                            Text('1 540 DT', style: AppTextStyles.dataLg(color: AppTheme.ink900).copyWith(fontSize: 16)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.ink400),
                fillColor: AppTheme.surface0,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Aucun historique pour le moment.',
                style: AppTextStyles.bodyLg(color: AppTheme.ink400),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
