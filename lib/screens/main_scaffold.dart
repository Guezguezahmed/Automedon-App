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
    return Scaffold(
      extendBody: true, // body goes behind the floating bar
      backgroundColor: const Color(0xFFF3F4F6),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SlidingNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary,
        activeIconColor: Colors.white,
        inactiveIconColor: const Color(0xFFB0B7C3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SLIDING NAV BAR
// ═══════════════════════════════════════════════════════════════════

/// A floating pill-shaped bottom navigation bar with a smooth sliding
/// circular indicator. Colors are fully customizable via constructor params.
class SlidingNavBar extends StatefulWidget {
  /// Currently selected tab index (0–3).
  final int selectedIndex;

  /// Callback fired when a tab is tapped.
  final ValueChanged<int> onItemTapped;

  // ── Customisable colors ──────────────────────────────────────────
  /// Background color of the pill container.
  final Color backgroundColor;

  /// Background color of the sliding circular indicator.
  final Color indicatorColor;

  /// Icon color when inside the active indicator.
  final Color activeIconColor;

  /// Icon color for inactive tabs.
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
  // ── Animation ───────────────────────────────────────────────────
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;

  /// Tracks the *previous* index so we can tween from old → new position.
  late int _previousIndex;

  // ── Layout constants ────────────────────────────────────────────
  static const double _barHeight     = 64.0;
  static const double _indicatorSize = 46.0;
  static const double _horizontalMargin = 24.0;
  static const double _verticalMargin   = 16.0;
  static const int    _itemCount = 5;

  // Icons — Home sits at index 2 (center slot)
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

    // Start fully at rest (the indicator is already at the right position).
    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(SlidingNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      // Restart the tween from the old position to the new one.
      _previousIndex = old.selectedIndex;
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Computes the LEFT edge of the indicator circle for a given [index],
  /// given the available [slotWidth].
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
            // Total usable width inside the pill
            final barWidth  = constraints.maxWidth;
            final slotWidth = barWidth / _itemCount;

            return Container(
              height: _barHeight,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(_barHeight / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                                color:
                                    widget.indicatorColor.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
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
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  INDIVIDUAL NAV ITEM
// ═══════════════════════════════════════════════════════════════════

/// A single icon slot inside the nav bar.
///
/// The icon itself never moves. Only its *color* cross-fades between
/// [activeIconColor] and [inactiveIconColor] using the shared
/// [animationController] from the parent.
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final Color activeIconColor;
  final Color inactiveIconColor;

  /// Shared controller from [SlidingNavBar] so the color fade is in sync
  /// with the sliding indicator.
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
        // Disable ripple for a cleaner premium look
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (_, __) {
                // Instantly swap color once the indicator reaches this slot
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
