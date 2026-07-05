import 'package:flutter/material.dart';
import '../theme.dart';

class SignalementsScreen extends StatelessWidget {
  const SignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signalements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  Text('Gérer les clients signalés', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3), // Yellow bg
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE047)), // Yellow border
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFCA8A04)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Attention: Tout signalement abusif peut entraîner la suspension de votre compte.',
                      style: TextStyle(color: Color(0xFFCA8A04), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Signaler un Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nom du client',
                      fillColor: const Color(0xFFF3F4F6),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'CIN',
                      fillColor: const Color(0xFFF3F4F6),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Numéro de téléphone',
                      fillColor: const Color(0xFFF3F4F6),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Motif du signalement (80 mots min.)',
                      fillColor: const Color(0xFFF3F4F6),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('0 / 80 mots min.', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 20),
                    label: const Text('Signaler le Client', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
