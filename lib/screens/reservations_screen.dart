import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, int> _pages = {'active': 1, 'confirmed': 1, 'completed': 1};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contrats', style: AppTextStyles.displayLg(context: context)),
              Text(
                'Location et Leasing',
                style: AppTextStyles.helperText(context: context),
              ),
            ],
          ),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: isDark ? AppTheme.neonViolet : AppTheme.primary600,
            unselectedLabelColor: isDark ? Colors.white60 : AppTheme.ink600,
            indicatorColor: isDark ? AppTheme.neonViolet : AppTheme.primary600,
            labelStyle: AppTextStyles.bodyLg(context: context).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.bodyLg(context: context),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Actifs'),
              Tab(text: 'Prévus'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList('active', isDark),
            _buildList('confirmed', isDark),
            _buildList('completed', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String status, bool isDark) {
    final page = _pages[status]!;
    final resAsync = ref.watch(
        reservationsProvider(ReservationsParams(status: status, page: page)));

    return resAsync.when(
      data: (data) {
        final items = data['reservations'] as List? ?? [];
        final total = data['total'] as int? ?? items.length;
        final pageSize = data['pageSize'] as int? ?? 20;
        final totalPages = (total / pageSize).ceil().clamp(1, 999);

        if (items.isEmpty) {
          return Center(
            child: AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'Aucun contrat',
              description: 'Aucune réservation trouvée dans cette catégorie.',
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.sp4,
                  AppTheme.sp4,
                  AppTheme.sp4,
                  120,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.sp3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      onTap: () => context.push('/reservations/${item['id']}'),
                      child: _buildReservationCard(item, isDark),
                    ),
                  );
                },
              ),
            ),
            if (totalPages > 1) _buildPaginationBar(status, page, totalPages, isDark),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: isDark ? AppTheme.neonViolet : AppTheme.primary600)),
      error: (e, _) => Center(
        child: Text(
          'Erreur: $e',
          style: AppTextStyles.bodyLg(color: AppTheme.danger),
        ),
      ),
    );
  }

  Widget _buildPaginationBar(String status, int page, int totalPages, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp4,
        vertical: AppTheme.sp3,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface0,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: page > 1
                ? (isDark ? AppTheme.neonViolet : AppTheme.primary600)
                : (isDark ? Colors.white24 : AppTheme.ink400.withValues(alpha: 0.3)),
            onPressed: page > 1
                ? () => setState(() => _pages[status] = page - 1)
                : null,
          ),
          Text(
            'Page $page / $totalPages',
            style: AppTextStyles.bodyMd(color: isDark ? Colors.white70 : AppTheme.ink600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: page < totalPages
                ? (isDark ? AppTheme.neonViolet : AppTheme.primary600)
                : (isDark ? Colors.white24 : AppTheme.ink400.withValues(alpha: 0.3)),
            onPressed: page < totalPages
                ? () => setState(() => _pages[status] = page + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> res, bool isDark) {
    final client = res['client_name'] ?? 'Client Inconnu';
    final contractNum =
        res['contract_number'] ?? res['reservation_number'] ?? 'N/A';
    final status = res['status'] ?? 'active';
    final price = res['total_price']?.toString() ?? '0';
    final car = res['car'] as Map<String, dynamic>? ?? {};
    final brand = car['brand'] ?? 'Auto';
    final model = car['model'] ?? '';
    final imgUrl = car['image_url'];

    const String startDate = "10 Jan 2024";
    const String endDate = "14 Jan 2024";

    Color statusColor;
    String statusText;
    Color dotColor;
    String paymentText;

    if (status == 'completed' || status == 'historique') {
      statusColor = isDark ? AppTheme.neonMint : AppTheme.success;
      statusText = 'Terminée';
      dotColor = isDark ? AppTheme.neonMint : AppTheme.success;
      paymentText = 'Payé';
    } else if (status == 'cancelled' || status == 'annulee') {
      statusColor = AppTheme.danger;
      statusText = 'Annulée';
      dotColor = AppTheme.warning;
      paymentText = 'Remboursé';
    } else {
      statusColor = isDark ? AppTheme.neonViolet : AppTheme.primary600;
      statusText = 'En cours';
      dotColor = isDark ? AppTheme.neonMint : AppTheme.success;
      paymentText = 'Payé';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp4),
      hasGlow: isDark,
      glowColor: isDark ? AppTheme.neonViolet : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client,
                      style: AppTextStyles.displayMd(color: isDark ? Colors.white : AppTheme.ink900),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        'CONTRAT $contractNum',
                        style: AppTextStyles.dataSm(color: isDark ? Colors.white70 : AppTheme.ink600),
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: statusText,
                color: statusColor,
                glow: isDark,
              )
            ],
          ),
          const SizedBox(height: AppTheme.sp4),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1642) : AppTheme.surfaceApp,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
            ),
            padding: const EdgeInsets.all(AppTheme.sp3),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 40,
                    color: isDark ? const Color(0xFF2A205E) : Colors.white,
                    child: imgUrl != null
                        ? Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.directions_car_outlined,
                              color: isDark ? AppTheme.neonViolet : AppTheme.ink400,
                            ),
                          )
                        : Icon(
                            Icons.directions_car_outlined,
                            color: isDark ? AppTheme.neonViolet : AppTheme.ink400,
                          ),
                  ),
                ),
                const SizedBox(width: AppTheme.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$brand $model',
                        style: AppTextStyles.bodyLg(color: isDark ? Colors.white : AppTheme.ink900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$startDate → $endDate',
                        style: AppTextStyles.caption(color: isDark ? Colors.white60 : AppTheme.ink600),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: isDark
                          ? [BoxShadow(color: dotColor.withValues(alpha: 0.6), blurRadius: 6)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppTheme.sp2),
                  Text(
                    paymentText,
                    style: AppTextStyles.bodyLg(color: isDark ? Colors.white70 : AppTheme.ink900),
                  ),
                ],
              ),
              Text(
                '$price DT',
                style: AppTextStyles.dataLg(color: isDark ? AppTheme.neonCyan : AppTheme.primary600),
              ),
            ],
          )
        ],
      ),
    );
  }
}