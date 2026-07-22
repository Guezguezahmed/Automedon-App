import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Fleet Control Deck — Design Tokens
// ─────────────────────────────────────────────────────────────────────────────

/// Centralized design token system for the Fleet Control Deck UI.
/// Follows the redesign brief's specification for premium telemetry feel.
class AppTheme {
  // ── Color Palette ────────────────────────────────────────────────────────

  /// Deep violet — primary actions, active states
  static const Color primary600 = Color(0xFF5B4FE0);

  /// Current brand purple — gradients, icons
  static const Color primary500 = Color(0xFF7C6FEA);

  /// Lighter tint — hover, secondary accents
  static const Color primary400 = Color(0xFF9C90F5);

  /// Headings — near-black, warm, not pure black
  static const Color ink900 = Color(0xFF14121F);

  /// Body/secondary text
  static const Color ink600 = Color(0xFF6B6478);

  /// Placeholder/disabled text
  static const Color ink400 = Color(0xFFA8A2B5);

  /// Cards — white surface
  static const Color surface0 = Color(0xFFFFFFFF);

  /// App background — faint violet-grey, elevated cards read as "raised"
  static const Color surfaceApp = Color(0xFFF5F4FA);

  /// Status colors — semantic
  static const Color success = Color(0xFF2FBE8F);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFF0544B);
  static const Color info = Color(0xFF4B9EF0);

  // ── Legacy aliases for backward compatibility ────────────────────────────
  static const Color primary = primary600;
  static const Color primaryDark = primary600;
  static const Color primaryLight = primary400;
  static const Color background = surfaceApp;
  static const Color surface = surface0;
  static const Color textPrimary = ink900;
  static const Color textSecondary = ink600;
  static const Color error = danger;

  // ── Glass & Glow Effects ─────────────────────────────────────────────────
  static Color get glassGill => Colors.white.withValues(alpha: 0.55);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.35);
  static Color get glowPrimary => primary600.withValues(alpha: 0.35);

  // ── Spacing (4/8pt scale) ────────────────────────────────────────────────
  static const double sp1 = 4.0;
  static const double sp2 = 8.0;
  static const double sp3 = 12.0;
  static const double sp4 = 16.0;
  static const double sp5 = 20.0;
  static const double sp6 = 24.0;
  static const double sp8 = 32.0;
  static const double sp10 = 40.0;

  // ── Border Radius ────────────────────────────────────────────────────────
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusFull = 999.0;

  // ── Shadows (layered, tinted) ────────────────────────────────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color.fromARGB(10, 20, 18, 31),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color.fromARGB(13, 20, 18, 31),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color.fromARGB(10, 20, 18, 31),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color.fromARGB(26, 91, 79, 224),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color.fromARGB(13, 20, 18, 31),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color.fromARGB(41, 91, 79, 224),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> shadowPress = [
    BoxShadow(
      color: Color.fromARGB(15, 20, 18, 31),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // ── Motion/Animation ─────────────────────────────────────────────────────
  static const Curve easeOutSoft = Cubic(0.16, 1, 0.3, 1);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationBase = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const int staggerStep = 40; // ms between list item animations

  // ─────────────────────────────────────────────────────────────────────────
  //  Theme Builder
  // ─────────────────────────────────────────────────────────────────────────

  // ── Dark Obsidian Palette ──────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A071B);
  static const Color darkSurface = Color(0xFF140F2D);
  static const Color darkBorder = Color(0xFF261D4C);
  static const Color darkInkPrimary = Color(0xFFFFFFFF);
  static const Color darkInkSecondary = Color(0xFF94A3B8);

  static const Color neonViolet = Color(0xFF7C6FEA);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonMint = Color(0xFF10B981);
  static const Color neonPink = Color(0xFFEC4899);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary600,
        secondary: primary400,
        surface: surface0,
        error: danger,
        surfaceContainer: surfaceApp,
      ),
      scaffoldBackgroundColor: surfaceApp,
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: neonViolet,
        secondary: neonBlue,
        surface: darkSurface,
        error: danger,
        surfaceContainer: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
    );
  }

  // ── Text Theme ───────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme({required bool isDark}) {
    final primaryColor = isDark ? darkInkPrimary : ink900;
    final secondaryColor = isDark ? darkInkSecondary : ink600;

    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.21,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.30,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.375,
        color: primaryColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.429,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.333,
        color: secondaryColor,
      ),
    );
  }

  // ── AppBar Theme ─────────────────────────────────────────────────────────

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    final bg = isDark ? darkBg : surfaceApp;
    final fg = isDark ? darkInkPrimary : ink900;

    return AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: fg),
      titleTextStyle: GoogleFonts.outfit(
        color: fg,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      toolbarHeight: 70,
    );
  }

  // ── Button Themes ───────────────────────────────────────────────────────

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        padding: const EdgeInsets.symmetric(vertical: sp4, horizontal: sp5),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    final fg = isDark ? darkInkPrimary : ink900;
    final border = isDark ? darkBorder : const Color(0xFFE5E7EB);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        padding: const EdgeInsets.symmetric(vertical: sp3, horizontal: sp4),
      ),
    );
  }

  // ── Input Theme ──────────────────────────────────────────────────────────

  static InputDecorationTheme _buildInputDecorationTheme({required bool isDark}) {
    final fill = isDark ? darkSurface : const Color(0xFFF3F4F6);
    final hint = isDark ? darkInkSecondary : ink400;

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: isDark ? const BorderSide(color: darkBorder) : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: isDark ? const BorderSide(color: darkBorder) : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary600, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: sp5, vertical: sp4),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: hint,
      ),
    );
  }

  // ── Card Theme ───────────────────────────────────────────────────────────

  static CardThemeData _buildCardTheme({required bool isDark}) {
    final color = isDark ? darkSurface : surface0;

    return CardThemeData(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: isDark ? const BorderSide(color: darkBorder, width: 1) : BorderSide.none,
      ),
      shadowColor: isDark ? Colors.transparent : primary600.withValues(alpha: 0.10),
      margin: EdgeInsets.zero,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Utility Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Press state scale — for buttons/cards on tap
  static const double pressScale = 0.97;

  /// Breathing animation amplitude (pixels)
  static const double breathingAmplitude = 3.0;
}
