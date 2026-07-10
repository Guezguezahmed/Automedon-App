import 'package:flutter/material.dart';
import '../theme.dart';
import 'partenaires_screen.dart';
class LeasingScreen extends StatelessWidget {
  const LeasingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINANCE', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Leasing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Gérez vos contrats de leasing', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Partenaire', style: TextStyle(color: AppTheme.textPrimary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nouveau'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('CONTRATS', '0', 'voitures')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('FINANCÉ', '0,000', 'DT')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('PAYÉ', '0,000', 'DT')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('RESTANT', '0', 'échéances')),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 4),
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Icon(Icons.description_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('Aucun contrat leasing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'Vous n\'avez pas encore ajouté de contrat de leasing à votre flotte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
