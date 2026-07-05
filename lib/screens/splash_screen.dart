import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Full-screen animated splash screen shown on app launch.
/// Automatically navigates to '/' after the animation completes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Main logo entrance ──────────────────────────────────────────
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // ── Text entrance (staggered after logo) ──────────────────────
  late AnimationController _textCtrl;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // ── Tagline (staggered after text) ────────────────────────────
  late AnimationController _tagCtrl;
  late Animation<double> _tagOpacity;

  // ── Dots loader ───────────────────────────────────────────────
  late AnimationController _dotsCtrl;

  // ── Background particles ──────────────────────────────────────
  late AnimationController _particleCtrl;

  // ── Exit fade ─────────────────────────────────────────────────
  late AnimationController _exitCtrl;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    // Logo: scale + fade in
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoScale = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));

    // Text: slide up + fade in (starts 400ms after logo)
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Tagline: fade in (starts 200ms after text)
    _tagCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _tagOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn));

    // Dots: continuous bounce loop
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

    // Particles: slow drift loop
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();

    // Exit: fade to white before navigating
    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();                              // 0.2s → 0.9s  logo
    await Future.delayed(const Duration(milliseconds: 100));
    await _textCtrl.forward();                              // 1.0s → 1.5s  text
    await Future.delayed(const Duration(milliseconds: 100));
    await _tagCtrl.forward();                               // 1.6s → 2.0s  tagline
    await Future.delayed(const Duration(milliseconds: 900)); // hold 0.9s
    await _exitCtrl.forward();                              // fade out
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _dotsCtrl.dispose();
    _particleCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitOpacity,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background gradient ─────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C6FF7), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Floating particles ──────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),

            // ── Main content ────────────────────────────────────
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo icon box
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: const Text(
                        'Automedon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Divider line
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _tagOpacity,
                    child: const Text(
                      'La solution SaaS N°1 en Tunisie',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bouncing dots loader
                  _DotsLoader(controller: _dotsCtrl),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOUNCING DOTS LOADER
// ═══════════════════════════════════════════════════════════════════
class _DotsLoader extends StatelessWidget {
  final AnimationController controller;
  const _DotsLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot is offset by 200ms
            final offset = i * 0.33;
            final t = ((controller.value - offset) % 1.0).clamp(0.0, 1.0);
            // Dot pulses: big → small → big in a sine wave
            final scale = 0.5 + 0.5 * sin(t * pi);
            final opacity = 0.4 + 0.6 * sin(t * pi);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BACKGROUND PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════
class _ParticlePainter extends CustomPainter {
  final double progress;

  // Fixed particle data (angle, radius, size) — deterministic, no Random
  static const List<List<double>> _particles = [
    [0.1, 0.12, 3.0], [0.3, 0.22, 2.0], [0.5, 0.08, 4.0],
    [0.7, 0.18, 2.5], [0.9, 0.30, 1.5], [0.15, 0.40, 3.5],
    [0.45, 0.35, 2.0], [0.65, 0.50, 1.5], [0.85, 0.25, 3.0],
    [0.25, 0.60, 2.5], [0.55, 0.70, 1.5], [0.75, 0.80, 3.0],
    [0.10, 0.75, 2.0], [0.40, 0.90, 2.5], [0.80, 0.65, 1.5],
    [0.20, 0.55, 4.0], [0.60, 0.15, 2.0], [0.90, 0.45, 3.0],
  ];

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);

    for (final p in _particles) {
      final angle = p[0] * 2 * pi + progress * 2 * pi * 0.2;
      final r = p[1];
      final radius = p[2];

      final dx = (r + 0.02 * sin(angle * 3)) * size.width;
      final dy = (p[0] + 0.03 * cos(angle * 2 + progress * pi)) % 1.0 * size.height;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
