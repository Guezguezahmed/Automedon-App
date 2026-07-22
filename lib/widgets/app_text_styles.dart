import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Centralized text style constants for Fleet Control Deck.
/// Organizes typography by role: Display, Body, Caption, and Data (mono).
class AppTextStyles {
  // ── Display — Outfit (geometric grotesk) ─────────────────────────────────

  static TextStyle displayLg({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.ink900);
    return GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.21,
      color: c,
    );
  }

  static TextStyle displayMd({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.ink900);
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.30,
      color: c,
    );
  }

  // ── Body — Inter ─────────────────────────────────────────────────────────

  static TextStyle bodyLg({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.ink900);
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.375,
      color: c,
    );
  }

  static TextStyle bodyMd({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : AppTheme.ink600);
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.429,
      color: c,
    );
  }

  // ── Caption — Inter ──────────────────────────────────────────────────────

  static TextStyle caption({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : AppTheme.ink600);
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
      color: c,
    );
  }

  // ── Data / Tabular (Mono) — Courier Prime ──────────────────────────────

  /// Large tabular data: stat counts (e.g., "8", "3", "3")
  static TextStyle dataLg({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.primary600);
    return GoogleFonts.courierPrime(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.182,
      color: c,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Small tabular data: license plates, contract IDs (e.g., "257TU3985")
  static TextStyle dataSm({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.ink900);
    return GoogleFonts.courierPrime(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.385,
      color: c,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // ── Utility styles ───────────────────────────────────────────────────────

  /// Small, bold label for badges and tags
  static TextStyle badgeLabel({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.ink900);
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.273,
      color: c,
    );
  }

  /// Subtle helper/hint text
  static TextStyle helperText({Color? color, BuildContext? context}) {
    final c = color ?? (context != null && Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : AppTheme.ink400);
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.333,
      color: c,
    );
  }
}
