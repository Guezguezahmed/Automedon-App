import 'package:flutter/material.dart';
import '../theme.dart';
import 'agences_screen.dart';
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.directions_car_outlined, color: Colors.pink, size: 20), // Closest to the icon in 193418
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  Text('0 services enregistrés', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgencesScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Agences', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nouveau'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 64, color: Color(0xFFD1D5DB)),
                    const SizedBox(height: 16),
                    const Text('Aucun service enregistré.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text(
                      'Commencez par ajouter votre premier service (transfert, mise à disposition...)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Nouveau Service', style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
