import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';
import 'car_detail_screen.dart';

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final carsAsync = ref.watch(carsProvider(_selectedFilter));

    return AppAmbientGlow(
        child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        title: Text('Parc Véhicules', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
    centerTitle: false,
    ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(isDark),
              _buildFilterChips(isDark),
              Expanded(
                child: carsAsync.when(
                  data: (data) {
                    final cars = data['cars'] as List? ?? [];
                    return ListView(
                      padding: const EdgeInsets.all(AppTheme.sp4),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          '${cars.length} véhicules trouvés',
                          style: AppTextStyles.bodyMd(
                            color: isDark ? Colors.white70 : AppTheme.ink600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.sp4),
                        ...cars.map((c) => _buildCarCard(c, isDark)),
                        const SizedBox(height: 140),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      'Erreur de chargement',
                      style: AppTextStyles.bodyLg(color: AppTheme.danger),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );

  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp4,
        vertical: AppTheme.sp2,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
              decoration: InputDecoration(
                hintText: 'Rechercher un véhicule...',
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white60 : AppTheme.ink400),
                fillColor: isDark ? AppTheme.darkSurface : AppTheme.surface0,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sp5,
                  vertical: AppTheme.sp3,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp3),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary600,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp4,
        vertical: AppTheme.sp2,
      ),
      child: Row(
        children: [
          _buildChip('Tous', null, isDark),
          const SizedBox(width: AppTheme.sp2),
          _buildChip('Disponible', 'disponible', isDark),
          const SizedBox(width: AppTheme.sp2),
          _buildChip('Loué', 'loue', isDark),
          const SizedBox(width: AppTheme.sp2),
          _buildChip('Maintenance', 'maintenance', isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp4,
          vertical: AppTheme.sp2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary600 : (isDark ? AppTheme.darkSurface : AppTheme.surface0),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isSelected ? AppTheme.shadowSm : null,
          border: Border.all(
            color: isSelected
                ? AppTheme.primary600
                : (isDark ? AppTheme.darkBorder : Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLg(
            color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppTheme.ink600),
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, bool isDark) {
    final brand = car['brand'] ?? '';
    final model = car['model'] ?? '';
    final plate = car['plate_number'] ?? '';
    final year = car['first_registration_year'] ?? '';
    final mileage = car['mileage'] ?? '';
    final status = car['status'] as String? ?? 'disponible';
    final imgUrl = car['image_url'];

    final primaryText = isDark ? Colors.white : AppTheme.ink900;
    final secondaryText = isDark ? Colors.white60 : AppTheme.ink600;
    final tileBg = isDark ? AppTheme.darkBg : AppTheme.surfaceApp;

    Color statusColor;
    String statusText;
    if (status == 'loue') {
      statusColor = AppTheme.warning;
      statusText = 'Loué';
    } else if (status == 'maintenance') {
      statusColor = AppTheme.danger;
      statusText = 'Maintenance';
    } else {
      statusColor = AppTheme.success;
      statusText = 'Disponible';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp4),
      child: AppCard(
        padding: EdgeInsets.zero,
        shadows: AppTheme.shadowMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMd),
                    topRight: Radius.circular(AppTheme.radiusMd),
                  ),
                  child: Container(
                    height: 180,
                    color: tileBg,
                    child: imgUrl != null
                        ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.directions_car_outlined,
                        size: 50,
                        color: isDark ? Colors.white24 : AppTheme.ink400,
                      ),
                    )
                        : Icon(
                      Icons.directions_car_outlined,
                      size: 80,
                      color: isDark ? Colors.white24 : AppTheme.ink400,
                    ),
                  ),
                ),
                Positioned(
                  top: AppTheme.sp3,
                  right: AppTheme.sp3,
                  child: AppStatusBadge(
                    label: statusText,
                    color: statusColor,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.sp4),
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
                          Text(
                            '$brand $model',
                            style: AppTextStyles.displayMd(color: primaryText),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tileBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  plate.toString(),
                                  style: AppTextStyles.dataSm(color: primaryText),
                                ),
                              ),
                              if (year.toString().isNotEmpty) ...[
                                Text(' • ', style: AppTextStyles.bodyMd(color: secondaryText)),
                                Text(year.toString(), style: AppTextStyles.bodyMd(color: secondaryText)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.sp4),
                  Row(
                    children: [
                      _buildInfoChip(Icons.local_gas_station_outlined, 'Diesel', isDark),
                      const SizedBox(width: AppTheme.sp2),
                      _buildInfoChip(Icons.settings_outlined, 'Automatique', isDark),
                      const SizedBox(width: AppTheme.sp2),
                      _buildInfoChip(Icons.speed_outlined, '$mileage km', isDark),
                    ],
                  ),
                  const SizedBox(height: AppTheme.sp4),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CarDetailScreen(car: car),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppTheme.primary600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Voir les détails',
                      style: AppTextStyles.bodyLg(color: AppTheme.primary600),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp2,
        vertical: AppTheme.sp1,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white60 : AppTheme.ink600),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption(color: isDark ? Colors.white60 : AppTheme.ink600),
          ),
        ],
      ),
    );
  }
}