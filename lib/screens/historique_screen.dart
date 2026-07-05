import 'package:flutter/material.dart';
import '../theme.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historique Flotte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('7 véhicules · 2 réservations · 1 540,000 DT de CA', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.directions_car_outlined, color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Voitures', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.trending_up, color: AppTheme.success, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CA Total', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('1 540 DT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                fillColor: Colors.transparent, // Like in the design
                filled: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Aucun historique pour le moment.', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          )
        ],
      ),
    );
  }
}
