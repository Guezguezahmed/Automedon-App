import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Independent page tracking per tab/status.
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contrats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Location et Leasing', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
          _buildList('active'),
          _buildList('confirmed'),
          _buildList('completed'),
        ],
      ),
    );
  }

  Widget _buildList(String status) {
    final page = _pages[status]!;
    final resAsync = ref.watch(reservationsProvider(ReservationsParams(status: status, page: page)));

    return resAsync.when(
      data: (data) {
        final items = data['reservations'] as List? ?? [];
        final total = data['total'] as int? ?? items.length;
        final pageSize = data['pageSize'] as int? ?? 20;
        final totalPages = (total / pageSize).ceil().clamp(1, 999);

        if (items.isEmpty) {
          return const Center(child: Text('Aucun contrat', style: TextStyle(color: AppTheme.textSecondary)));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => context.push('/reservations/${item['id']}'),
                    child: _buildReservationCard(item),
                  );
                },
              ),
            ),
            if (totalPages > 1) _buildPaginationBar(status, page, totalPages),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  Widget _buildPaginationBar(String status, int page, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: page > 1 ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.3),
            onPressed: page > 1 ? () => setState(() => _pages[status] = page - 1) : null,
          ),
          Text(
            'Page $page / $totalPages',
            style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: page < totalPages ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.3),
            onPressed: page < totalPages ? () => setState(() => _pages[status] = page + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> res) {
    final client = res['client_name'] ?? 'Client Inconnu';
    final contractNum = res['contract_number'] ?? res['reservation_number'] ?? 'N/A';
    final status = res['status'] ?? 'active';
    final price = res['total_price']?.toString() ?? '0';
    final car = res['car'] as Map<String, dynamic>? ?? {};
    final brand = car['brand'] ?? 'Auto';
    final model = car['model'] ?? '';
    final imgUrl = car['image_url'];

    // Dates formatting mock
    final String startDate = "10 Jan 2024";
    final String endDate = "14 Jan 2024";

    Color badgeColor;
    Color badgeTextCol;
    String badgeText;
    Color dotColor;
    String paymentText;

    if (status == 'completed' || status == 'historique') {
      badgeColor = AppTheme.success.withOpacity(0.15);
      badgeTextCol = AppTheme.success;
      badgeText = 'Terminée';
      dotColor = AppTheme.success;
      paymentText = 'Payé';
    } else if (status == 'cancelled' || status == 'annulee') {
      badgeColor = AppTheme.error.withOpacity(0.15);
      badgeTextCol = AppTheme.error;
      badgeText = 'Annulée';
      dotColor = AppTheme.warning;
      paymentText = 'Remboursé';
    } else {
      badgeColor = AppTheme.primary.withOpacity(0.15);
      badgeTextCol = AppTheme.primary;
      badgeText = 'En cours';
      dotColor = AppTheme.success;
      paymentText = 'Payé';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('CONTRAT $contractNum', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(badgeText, style: TextStyle(color: badgeTextCol, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 40,
                      color: Colors.grey.shade300,
                      child: imgUrl != null
                          ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.car_crash))
                          : const Icon(Icons.directions_car, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$brand $model', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('$startDate → $endDate', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(paymentText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Text('$price DT', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            )
          ],
        ),
      ),
    );
  }
}