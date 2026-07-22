import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'fleet_screen.dart';
import 'reservations_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Main scaffold that hosts the 5 screens and the custom floating nav bar.
/// [extendBody] is true so the body scrolls behind the floating bar.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 2; // Home is center (index 2)

  // 5 screens mapped to 5 nav items — Home is in the middle (index 2)
  final List<Widget> _screens = const [
    FleetScreen(),
    ReservationsScreen(),
    DashboardScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // body goes behind the floating bar
      backgroundColor: isDark ? const Color(0xFF0A071B) : AppTheme.surfaceApp,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SlidingNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) => setState(() => _selectedIndex = i),
        backgroundColor: isDark
            ? const Color(0xFF140F2D).withValues(alpha: 0.88)
            : AppTheme.glassGill,
        indicatorColor: isDark ? const Color(0xFF7C6FEA) : AppTheme.primary600,
        activeIconColor: Colors.white,
        inactiveIconColor: isDark ? Colors.white38 : AppTheme.ink400,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SLIDING NAV BAR — Frosted Glass Control Deck
// ═══════════════════════════════════════════════════════════════════

/// A floating pill-shaped bottom navigation bar with a smooth sliding
/// circular indicator and glass elevation.
class SlidingNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Color backgroundColor;
  final Color indicatorColor;
  final Color activeIconColor;
  final Color inactiveIconColor;

  const SlidingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
  });

  @override
  State<SlidingNavBar> createState() => _SlidingNavBarState();
}

class _SlidingNavBarState extends State<SlidingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late int _previousIndex;

  static const double _barHeight     = 66.0;
  static const double _indicatorSize = 48.0;
  static const double _horizontalMargin = 20.0;
  static const double _verticalMargin   = 16.0;
  static const int    _itemCount = 5;

  static const List<IconData> _icons = [
    Icons.directions_car_outlined,
    Icons.calendar_today_outlined,
    Icons.home_outlined,
    Icons.notifications_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: AppTheme.easeOutSoft),
    );
  }

  @override
  void didUpdateWidget(SlidingNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _previousIndex = old.selectedIndex;
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _indicatorLeft(int index, double slotWidth) {
    final center = slotWidth * index + slotWidth / 2;
    return center - _indicatorSize / 2;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: _horizontalMargin,
          right: _horizontalMargin,
          bottom: _verticalMargin,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth  = constraints.maxWidth;
            final slotWidth = barWidth / _itemCount;

            return Container(
              height: _barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowLg,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Layer 1: sliding circular indicator ──────────
                        AnimatedBuilder(
                          animation: _slideAnim,
                          builder: (_, __) {
                            final fromLeft =
                                _indicatorLeft(_previousIndex, slotWidth);
                            final toLeft =
                                _indicatorLeft(widget.selectedIndex, slotWidth);
                            final currentLeft =
                                fromLeft + (toLeft - fromLeft) * _slideAnim.value;

                            return Positioned(
                              top: (_barHeight - _indicatorSize) / 2,
                              left: currentLeft,
                              child: Container(
                                width: _indicatorSize,
                                height: _indicatorSize,
                                decoration: BoxDecoration(
                                  color: widget.indicatorColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.indicatorColor.withValues(alpha: 0.38),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // ── Layer 2: icon row ─────────────────────────────
                        Row(
                          children: List.generate(_itemCount, (i) {
                            return _NavItem(
                              index: i,
                              icon: _icons[i],
                              isSelected: widget.selectedIndex == i,
                              activeIconColor: widget.activeIconColor,
                              inactiveIconColor: widget.inactiveIconColor,
                              animationController: _ctrl,
                              onTap: () => widget.onItemTapped(i),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final AnimationController animationController;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.isSelected,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (_, __) {
                final color = isSelected ? activeIconColor : inactiveIconColor;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    icon,
                    key: ValueKey(isSelected),
                    size: 22,
                    color: color,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
