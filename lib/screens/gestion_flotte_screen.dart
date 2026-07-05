import 'package:flutter/material.dart';
import '../theme.dart';

class GestionFlotteScreen extends StatelessWidget {
  const GestionFlotteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestion Flotte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Gérez votre flotte', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Parc', style: TextStyle(color: AppTheme.textPrimary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Voiture'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.directions_car_outlined, color: AppTheme.textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Peugeot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const Text('2', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('208 Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                        child: const Text('112 TUN 4567', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Text('Disponible', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.description_outlined, size: 14, color: AppTheme.textSecondary),
                          SizedBox(width: 4),
                          Text('4/4', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
