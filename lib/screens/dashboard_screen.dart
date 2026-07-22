import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import 'vision360_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meAsync = ref.watch(meProvider);
    final visionAsync = ref.watch(vision360Provider);

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(meAsync, isDark),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp4),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTimeToggle(isDark),
                  const SizedBox(height: AppTheme.sp4),
                  _buildRevenueCard(isDark),
                  const SizedBox(height: AppTheme.sp4),
                  Row(
                    children: [
                      Expanded(child: _buildFleetStateCard(isDark)),
                      const SizedBox(width: AppTheme.sp4),
                      Expanded(child: _buildOccupancyCard(isDark)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.sp8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'À faire aujourd\'hui',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.ink900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Vision360Screen()),
                          );
                        },
                        child: Text(
                          'Voir tout',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.sp2),
                  _buildTasksList(context, visionAsync, isDark),
                  const SizedBox(height: 140),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> meAsync, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E1548), Color(0xFF110B2D)]
              : const [Color(0xFF5B4FE0), Color(0xFF3B2DB8), Color(0xFF23187F)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, left: AppTheme.sp6, right: AppTheme.sp6, bottom: AppTheme.sp8),
            child: meAsync.when(
              data: (data) {
                final user = data['user'] as Map<String, dynamic>? ?? {};
                final name = user['username'] as String? ?? 'User';
                final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

                return Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour 👋',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (_, __) => const Text('Erreur', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: AppCard(
        padding: const EdgeInsets.all(4),
        shadows: isDark ? null : AppTheme.shadowLg,
        borderRadius: AppTheme.radiusFull,
        child: Row(
          children: [
            Expanded(child: _buildToggleBtn('Semaine', false, isDark)),
            Expanded(child: _buildToggleBtn('Mois', true, isDark)),
            Expanded(child: _buildToggleBtn('Année', false, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool active, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.sp2),
      decoration: BoxDecoration(
        color: active
            ? (isDark ? AppTheme.neonViolet : AppTheme.primary600)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: active
              ? Colors.white
              : (isDark ? Colors.white60 : AppTheme.ink600),
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildRevenueCard(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.sp5),
        shadows: isDark ? null : AppTheme.shadowMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chiffre d\'Affaires',
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white60 : AppTheme.ink600,
                    fontSize: 13,
                  ),
                ),
                AppStatusBadge(
                  label: '+12.4%',
                  color: isDark ? AppTheme.neonMint : AppTheme.success,
                  icon: Icons.arrow_outward,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '6 150',
                  style: GoogleFonts.courierPrime(
                    color: isDark ? Colors.white : AppTheme.ink900,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppTheme.sp1),
                Text(
                  ',000 DT',
                  style: GoogleFonts.courierPrime(
                    color: isDark ? Colors.white60 : AppTheme.ink600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp4),
            SizedBox(
              height: 54,
              child: CustomPaint(
                painter: _DummyChartPainter(isDark: isDark),
                size: Size.infinite,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStateCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp4),
      shadows: isDark ? null : AppTheme.shadowMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÉTAT DU PARC',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white54 : AppTheme.ink600,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppTheme.sp3),
          _buildFleetRow(isDark ? AppTheme.neonMint : AppTheme.success, 'Dispos', '4', isDark),
          const SizedBox(height: AppTheme.sp2),
          _buildFleetRow(AppTheme.warning, 'Loués', '2', isDark),
          const SizedBox(height: AppTheme.sp2),
          _buildFleetRow(AppTheme.danger, 'Maint.', '1', isDark),
        ],
      ),
    );
  }

  Widget _buildFleetRow(Color color, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.sp2),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isDark ? Colors.white70 : AppTheme.ink900,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.courierPrime(
            color: isDark ? Colors.white : AppTheme.ink900,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp4),
      shadows: isDark ? null : AppTheme.shadowMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline, color: AppTheme.warning, size: 16),
              const SizedBox(width: AppTheme.sp1),
              Text(
                'OCCUPATION',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white54 : AppTheme.ink600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '65',
                style: GoogleFonts.courierPrime(
                  color: isDark ? Colors.white : AppTheme.ink900,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '%',
                style: GoogleFonts.courierPrime(
                  color: isDark ? Colors.white60 : AppTheme.ink600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: isDark ? Colors.white10 : AppTheme.surfaceApp,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.neonCyan : AppTheme.primary600,
              ),
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, AsyncValue<Map<String, dynamic>> visionAsync, bool isDark) {
    return visionAsync.when(
      data: (data) {
        final soon = data['returningSoon'] as List? ?? [];
        if (soon.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.sp4),
            child: Text(
              'Rien de prévu aujourd\'hui',
              style: GoogleFonts.inter(color: isDark ? Colors.white54 : AppTheme.ink600),
            ),
          );
        }
        return Column(
          children: soon.take(3).map((e) => _buildTaskCard(context, e, isDark)).toList(),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: isDark ? AppTheme.neonViolet : AppTheme.primary600)),
      error: (_, __) => Text(
        'Erreur de chargement',
        style: GoogleFonts.inter(color: AppTheme.danger),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, dynamic task, bool isDark) {
    return AppCard(
      padding: EdgeInsets.zero,
      shadows: isDark ? null : AppTheme.shadowSm,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const Vision360Screen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border(
            left: BorderSide(
              color: isDark ? AppTheme.neonCyan : AppTheme.warning,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.sp4),
        child: Row(
          children: [
            AppIconCircle(
              icon: Icons.refresh,
              color: isDark ? AppTheme.neonCyan : AppTheme.warning,
              backgroundColor: (isDark ? AppTheme.neonCyan : AppTheme.warning).withValues(alpha: 0.15),
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppTheme.sp4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retour prévu à 14:00',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : AppTheme.ink900,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task['brand']} ${task['model']} • ${task['client_name']}',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white60 : AppTheme.ink600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : AppTheme.ink400),
          ],
        ),
      ),
    );
  }
}

class _DummyChartPainter extends CustomPainter {
  final bool isDark;
  _DummyChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = isDark ? AppTheme.neonCyan : AppTheme.primary600;

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.1, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          strokeColor.withValues(alpha: 0.35),
          strokeColor.withValues(alpha: 0.0),
        ],
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