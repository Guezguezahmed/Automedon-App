import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme.dart';
import 'app_text_styles.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED UI KIT WIDGETS WITH AMBIENT GLOW & DARK OBSIDIAN GLASS
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  AppAmbientGlow — Ambient background radial glow orbs for high-end atmosphere
// ─────────────────────────────────────────────────────────────────────────────

class AppAmbientGlow extends StatelessWidget {
  final Widget child;
  final Color? glowColor1;
  final Color? glowColor2;

  const AppAmbientGlow({
    super.key,
    required this.child,
    this.glowColor1,
    this.glowColor2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return child;

    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (glowColor1 ?? AppTheme.neonViolet).withValues(alpha: 0.22),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: -40,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (glowColor2 ?? AppTheme.neonCyan).withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppCard — Elevated glass card with ambient glow support
// ─────────────────────────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final List<BoxShadow>? shadows;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? glowColor;
  final bool hasGlow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.shadows,
    this.backgroundColor,
    this.borderRadius,
    this.glowColor,
    this.hasGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppTheme.radiusMd;
    final defaultBg = isDark ? AppTheme.darkSurface : AppTheme.surface0;
    final bg = backgroundColor ?? defaultBg;

    // Glowing shadows
    List<BoxShadow>? shadowList;
    if (isDark) {
      if (hasGlow || glowColor != null) {
        final gColor = glowColor ?? AppTheme.neonViolet;
        shadowList = [
          BoxShadow(
            color: gColor.withValues(alpha: 0.30),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ];
      } else {
        shadowList = shadows;
      }
    } else {
      shadowList = shadows ?? AppTheme.shadowMd;
    }

    final border = isDark
        ? Border.all(
            color: (glowColor ?? Colors.white).withValues(alpha: (hasGlow || glowColor != null) ? 0.25 : 0.08),
            width: (hasGlow || glowColor != null) ? 1.5 : 1.0,
          )
        : Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8), width: 1.0);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.sp4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadowList,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppStatChip — Data number (mono) + label with theme adaptability
// ─────────────────────────────────────────────────────────────────────────────

class AppStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;

  const AppStatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valCol = valueColor ?? (isDark ? Colors.white : AppTheme.ink900);
    final lblCol = isDark ? Colors.white60 : AppTheme.ink600;

    return Column(
      children: [
        if (icon != null)
          Icon(icon, color: iconColor ?? (isDark ? AppTheme.neonViolet : AppTheme.primary600), size: 18),
        if (icon != null) const SizedBox(height: AppTheme.sp2),
        Text(
          value,
          style: AppTextStyles.dataLg(color: valCol),
        ),
        const SizedBox(height: AppTheme.sp1),
        Text(
          label,
          style: AppTextStyles.helperText(color: lblCol),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppStatusBadge — Glowing dot + colored pill
// ─────────────────────────────────────────────────────────────────────────────

class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool glow;
  final IconData? icon;
  final bool showBorder;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.glow = true,
    this.icon,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp3,
        vertical: AppTheme.sp1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: showBorder ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: glow
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.60),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: AppTheme.sp2),
          ],
          Text(
            label,
            style: AppTextStyles.badgeLabel(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppIconCircle — Standardized icon container with glow option
// ─────────────────────────────────────────────────────────────────────────────

class AppIconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double? iconSize;
  final bool hasGlow;

  const AppIconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = 36,
    this.iconSize,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? color.withValues(alpha: isDark ? 0.20 : 0.12);
    final iSize = iconSize ?? (size * 0.5);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.35 : 0.15),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: iSize),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppGlassBadge — Frosted glass pill (header use)
// ─────────────────────────────────────────────────────────────────────────────

class AppGlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? dotColor;

  const AppGlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp3,
            vertical: AppTheme.sp1,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppTheme.glassGill,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor!.withValues(alpha: 0.60),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.sp2),
              ] else if (icon != null) ...[
                Icon(icon, size: 14, color: iconColor ?? Colors.white),
                const SizedBox(width: AppTheme.sp1),
              ],
              Text(
                label,
                style: AppTextStyles.badgeLabel(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppPrimaryButton — Elevated glowing button with press feedback
// ─────────────────────────────────────────────────────────────────────────────

class AppPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? color;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.color,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.durationFast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: AppTheme.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.easeOutSoft),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.isLoading || widget.onPressed == null) return;

    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnColor = widget.color ?? (isDark ? AppTheme.neonViolet : AppTheme.primary600);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, __) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: btnColor.withValues(alpha: isDark ? 0.45 : 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _handlePress,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                elevation: 0,
              ),
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(widget.icon ?? Icons.add, size: 20, color: Colors.white),
              label: Text(
                widget.label,
                style: AppTextStyles.bodyLg(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppEmptyState — Breathing icon + display type heading
// ─────────────────────────────────────────────────────────────────────────────

class AppEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onActionPressed;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onActionPressed,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<AppEmptyState> createState() => _AppEmptyStateState();
}

class _AppEmptyStateState extends State<AppEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnim;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnim = Tween<double>(
      begin: -AppTheme.breathingAmplitude,
      end: AppTheme.breathingAmplitude,
    ).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final callback = widget.onActionPressed ?? widget.onAction;
    final glowColor = isDark ? AppTheme.neonViolet : AppTheme.primary600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _breathingAnim,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, _breathingAnim.value),
                      child: Icon(
                        widget.icon,
                        size: 64,
                        color: glowColor,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp8),
            Text(
              widget.title,
              style: AppTextStyles.displayMd(context: context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              widget.description,
              style: AppTextStyles.bodyMd(context: context),
              textAlign: TextAlign.center,
            ),
            if (callback != null) ...[
              const SizedBox(height: AppTheme.sp6),
              AppPrimaryButton(
                label: widget.actionLabel ?? 'Action',
                onPressed: callback,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppInfoBanner — Tinted info strip (replaces bare gray text)
// ─────────────────────────────────────────────────────────────────────────────

class AppInfoBanner extends StatelessWidget {
  final String? text;
  final String? message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  const AppInfoBanner({
    super.key,
    this.text,
    this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerText = text ?? message ?? '';
    final accent = isDark ? AppTheme.neonCyan : AppTheme.primary600;
    final bgColor = backgroundColor ?? accent.withValues(alpha: isDark ? 0.15 : 0.08);
    final txtColor = textColor ?? (isDark ? Colors.white : AppTheme.ink900);
    final icnColor = iconColor ?? accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp4,
        vertical: AppTheme.sp3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: borderColor ?? accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: icnColor, size: 18),
            const SizedBox(width: AppTheme.sp2),
          ],
          Expanded(
            child: Text(
              bannerText,
              style: AppTextStyles.bodyMd(color: txtColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppGlassPill — Floating glass navigation pill with neon glow
// ─────────────────────────────────────────────────────────────────────────────

class AppGlassPill extends StatelessWidget {
  final Widget child;
  final List<BoxShadow>? shadows;

  const AppGlassPill({
    super.key,
    required this.child,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF140F2D).withValues(alpha: 0.85) : AppTheme.glassGill,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.glassBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: shadows ??
                (isDark
                    ? [
                        BoxShadow(
                          color: AppTheme.neonViolet.withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 1,
                        )
                      ]
                    : AppTheme.shadowLg),
          ),
          child: child,
        ),
      ),
    );
  }
}
