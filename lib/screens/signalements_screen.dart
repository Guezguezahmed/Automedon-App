import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class SignalementsScreen extends StatelessWidget {
  const SignalementsScreen({super.key});

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
              icon: Icons.warning_amber_rounded,
              color: AppTheme.danger,
              backgroundColor: Color(0x1AF0544B),
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppTheme.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Signalements', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
                  Text(
                    'Gérer les clients signalés',
                    style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.sp4),
        child: Column(
          children: [
            const AppInfoBanner(
              message: 'Attention: Tout signalement abusif peut entraîner la suspension de votre compte.',
              icon: Icons.warning_amber_rounded,
              backgroundColor: Color(0xFFFEF9C3),
              borderColor: Color(0xFFFDE047),
              textColor: Color(0xFFCA8A04),
              iconColor: Color(0xFFCA8A04),
            ),
            const SizedBox(height: AppTheme.sp6),
            AppCard(
              padding: const EdgeInsets.all(AppTheme.sp6),
              shadows: AppTheme.shadowMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Signaler un Client', style: AppTextStyles.displayMd()),
                  const SizedBox(height: AppTheme.sp6),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nom du client',
                      fillColor: AppTheme.surfaceApp,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'CIN',
                      fillColor: AppTheme.surfaceApp,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Numéro de téléphone',
                      fillColor: AppTheme.surfaceApp,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp4),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Motif du signalement (80 mots min.)',
                      fillColor: AppTheme.surfaceApp,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp2),
                  Text(
                    '0 / 80 mots min.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.caption(color: AppTheme.ink600),
                  ),
                  const SizedBox(height: AppTheme.sp6),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 20),
                    label: Text(
                      'Signaler le Client',
                      style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
    );
  }
}
