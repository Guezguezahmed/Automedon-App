import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';
import 'agences_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        title: Row(
          children: [
            const AppIconCircle(
              icon: Icons.directions_car_outlined,
              color: Color(0xFFEC4899),
              backgroundColor: Color(0x1AEC4899),
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppTheme.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Services', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
                  Text(
                    '0 services enregistrés',
                    style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp4,
              vertical: AppTheme.sp2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgencesScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sp4,
                      vertical: AppTheme.sp2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Agences',
                    style: AppTextStyles.bodyLg(color: AppTheme.ink900),
                  ),
                ),
                const SizedBox(width: AppTheme.sp2),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sp4,
                      vertical: AppTheme.sp2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Nouveau',
                    style: AppTextStyles.bodyLg(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppEmptyState(
              icon: Icons.directions_car_outlined,
              title: 'Aucun service enregistré.',
              description:
                  'Commencez par ajouter votre premier service (transfert, mise à disposition...)',
              actionLabel: 'Nouveau Service',
              onAction: () {},
            ),
          ),
        ],
      ),
    ),
    );
  }
}
