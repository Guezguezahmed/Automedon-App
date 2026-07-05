import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    final visionAsync = ref.watch(vision360Provider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(meAsync),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTimeToggle(),
                const SizedBox(height: 16),
                _buildRevenueCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildFleetStateCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildOccupancyCard()),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('À faire aujourd\'hui', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voir tout', style: TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTasksList(visionAsync),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> meAsync) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: meAsync.when(
        data: (data) {
          final user = data['user'];
          final name = user['username'] ?? 'User';
          final initials = name.toString().substring(0, 2).toUpperCase();

          return Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bonjour 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => const Text('Erreur', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTimeToggle() {
    // Transform up slightly to overlap header
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildToggleBtn('Semaine', false)),
            Expanded(child: _buildToggleBtn('Mois', true)),
            Expanded(child: _buildToggleBtn('Année', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        text, 
        style: TextStyle(
          color: active ? Colors.white : AppTheme.textSecondary,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        )
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chiffre d\'Affaires', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_outward, color: AppTheme.success, size: 14),
                        SizedBox(width: 4),
                        Text('+12.4%', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '6 150', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppTheme.textPrimary)),
                    TextSpan(text: ',000 DT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
                  ]
                )
              ),
              const SizedBox(height: 16),
              // Dummy chart curve
              SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: _DummyChartPainter(),
                  size: Size.infinite,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFleetStateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ÉTAT DU PARC', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 12),
            _buildFleetRow(AppTheme.success, 'Dispos', '4'),
            const SizedBox(height: 8),
            _buildFleetRow(AppTheme.warning, 'Loués', '2'),
            const SizedBox(height: 8),
            _buildFleetRow(AppTheme.error, 'Maint.', '1'),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetRow(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildOccupancyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart_outline, color: AppTheme.warning, size: 16),
                SizedBox(width: 4),
                Text('OCCUPATION', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 16),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '65', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppTheme.textPrimary)),
                  TextSpan(text: '%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
                ]
              )
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.65,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(AsyncValue<Map<String, dynamic>> visionAsync) {
    return visionAsync.when(
      data: (data) {
        final soon = data['returningSoon'] as List? ?? [];
        if (soon.isEmpty) return const Text('Rien de prévu');
        return Column(
          children: soon.take(3).map((e) => _buildTaskCard(e)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur'),
    );
  }

  Widget _buildTaskCard(dynamic task) {
    // We mock the task card based on the design
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: AppTheme.warning, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.refresh, color: AppTheme.warning, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Retour prévu à 14:00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${task['brand']} ${task['model']} • ${task['client_name']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DummyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.4, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.1, size.width, size.height * 0.2);
    
    canvas.drawPath(path, paint);

    // Gradient fill below path
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.primary.withOpacity(0.2), AppTheme.primary.withOpacity(0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
