import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class LeasingPartner {
  final String name;
  final int contractsCount;
  final int carsCount;
  final num amount;

  const LeasingPartner({
    required this.name,
    required this.contractsCount,
    required this.carsCount,
    required this.amount,
  });
}

final List<LeasingPartner> _mockPartners = [
  const LeasingPartner(
    name: 'Tunisie Leasing & Factoring (TLF) (Groupe Amen)',
    contractsCount: 0,
    carsCount: 0,
    amount: 0,
  ),
];

class PartenairesScreen extends StatelessWidget {
  const PartenairesScreen({super.key});

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
              icon: Icons.handshake_outlined,
              color: AppTheme.info,
              backgroundColor: Color(0x1A4B9EF0),
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppTheme.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Partenaires Leasing', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
                  Text(
                    '${_mockPartners.length} société de leasing',
                    style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _mockPartners.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppTheme.sp4, AppTheme.sp2, AppTheme.sp4, 120),
              itemCount: _mockPartners.length,
              itemBuilder: (context, i) => _PartnerCard(partner: _mockPartners[i]),
            ),
      ),
    );
  }

  Widget _buildEmpty() {
    return AppEmptyState(
      icon: Icons.account_balance_outlined,
      title: 'Aucun partenaire',
      description: 'Les banques et sociétés de leasing apparaîtront ici.',
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final LeasingPartner partner;

  const _PartnerCard({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp3),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.sp4),
        shadows: AppTheme.shadowSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    partner.name,
                    style: AppTextStyles.displayMd(),
                  ),
                ),
                const SizedBox(width: AppTheme.sp2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3, vertical: AppTheme.sp2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceApp,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    '${partner.amount.toStringAsFixed(3)} DT',
                    style: AppTextStyles.dataSm(color: AppTheme.ink900),
                  ),
                ),
                const SizedBox(width: AppTheme.sp2),
                GestureDetector(
                  onTap: () => _showReadOnlyMessage(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.sp2),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp2),
            Text(
              '${partner.contractsCount} contrat(s) · ${partner.carsCount} voiture(s)',
              style: AppTextStyles.bodyMd(),
            ),
          ],
        ),
      ),
    );
  }

  void _showReadOnlyMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: Text('Action indisponible', style: AppTextStyles.displayMd()),
        content: Text(
          'La suppression de partenaires n\'est pas encore disponible depuis l\'application mobile.',
          style: AppTextStyles.bodyMd(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: AppTextStyles.bodyLg(color: AppTheme.primary600)),
          ),
        ],
      ),
    );
  }
}