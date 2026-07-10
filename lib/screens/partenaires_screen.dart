import 'package:flutter/material.dart';
import '../theme.dart';

// ---------------------------------------------------------------------------
// TODO(backend): MOBILE_API.md ne prévoit aucun endpoint pour les
// partenaires de leasing (module purement back-office sur le web). Cet
// écran utilise donc des données MOCKÉES en lecture seule, pour valider
// le design. S'il doit vraiment apparaître dans l'app mobile, il faudra
// définir avec le backend owner un endpoint du type :
//   GET /mobile-leasing-partners   -> liste des partenaires
// ---------------------------------------------------------------------------

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handshake_outlined, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Partenaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Text(
                    '${_mockPartners.length} actif(s)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _mockPartners.length,
        itemBuilder: (context, i) => _PartnerCard(partner: _mockPartners[i]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_outlined, color: AppTheme.textSecondary, size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Aucun partenaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
              'Les banques et sociétés de leasing apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final LeasingPartner partner;
  final VoidCallback? onDelete;

  const _PartnerCard({required this.partner, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  partner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, height: 1.35),
                ),
              ),
              const SizedBox(width: 10),
              // Montant financé/dû pour ce partenaire -- lecture seule ici
              // (champ éditable sur le web, l'API mobile ne le permet pas).
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${partner.amount.toStringAsFixed(3)} DT',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              // TODO(backend): suppression indisponible -- l'API mobile est
              // en lecture seule (MOBILE_API.md). Le bouton reste visible
              // pour matcher le design web, mais désactivé + explique
              // pourquoi au tap plutôt que de disparaître silencieusement.
              GestureDetector(
                onTap: onDelete ?? () => _showReadOnlyMessage(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${partner.contractsCount} contrat(s) · ${partner.carsCount} voiture(s)',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showReadOnlyMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Action indisponible'),
        content: const Text(
          'La suppression de partenaires n\'est pas encore disponible depuis l\'application mobile.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}