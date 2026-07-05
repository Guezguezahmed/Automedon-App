import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme.dart';

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider(_selectedFilter));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Parc Véhicules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: carsAsync.when(
              data: (data) {
                final cars = data['cars'] as List? ?? [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${cars.length} véhicules trouvés', style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ...cars.map((c) => _buildCarCard(c)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Erreur de chargement')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un véhicule...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                fillColor: const Color(0xFFF3F4F6),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('Tous', null),
          const SizedBox(width: 8),
          _buildChip('Disponible', 'disponible'),
          const SizedBox(width: 8),
          _buildChip('Loué', 'loue'),
          const SizedBox(width: 8),
          _buildChip('Maintenance', 'maintenance'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    // For price mock since it's not strictly in GET /mobile-cars response directly usually,
    // though the user might have custom fields.
    final brand = car['brand'] ?? '';
    final model = car['model'] ?? '';
    final plate = car['plate_number'] ?? '';
    final year = car['first_registration_year'] ?? '';
    final mileage = car['mileage'] ?? '';
    final status = car['status'] as String? ?? 'disponible';
    final imgUrl = car['image_url'];

    Color statusColor;
    String statusText;
    if (status == 'loue') {
      statusColor = AppTheme.warning;
      statusText = 'Loué';
    } else if (status == 'maintenance') {
      statusColor = AppTheme.error;
      statusText = 'Maintenance';
    } else {
      statusColor = AppTheme.success;
      statusText = 'Disponible';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                color: Colors.grey.shade300,
                // Replace with Image.network when API is real
                child: imgUrl != null 
                    ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.car_crash, size: 50, color: Colors.grey))
                    : const Icon(Icons.directions_car, size: 80, color: Colors.white),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$brand $model', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text('$plate • $year', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('150 DT', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('/jour', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.local_gas_station_outlined, 'Diesel'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.settings_outlined, 'Automatique'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.speed_outlined, '$mileage km'),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                  child: const Text('Voir les détails', style: TextStyle(color: AppTheme.primary)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
