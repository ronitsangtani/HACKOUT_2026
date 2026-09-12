import 'package:flutter/material.dart';

/// EcoLoop visual theme configuration.
/// Implements a bright, playful, tactile Duolingo-inspired gamified design system.
class AppTheme {
  AppTheme._();

  // Signature Duolingo Gamified Color Palette
  static const Color duoGreen = Color(0xFF58CC02);       // Signature vibrant lime green
  static const Color duoGreenDark = Color(0xFF46A302);   // 3D bottom border bevel
  static const Color duoGreenLight = Color(0xFFD7FFB8);  // Soft green badge/pill background

  static const Color duoBlue = Color(0xFF1CB0F6);        // Gamified gems / eco points
  static const Color duoBlueDark = Color(0xFF1899D6);    // Blue 3D bevel
  static const Color duoBlueLight = Color(0xFFDDF4FF);   // Soft blue pill background

  static const Color duoOrange = Color(0xFFFF9600);      // Streaks 🔥
  static const Color duoOrangeDark = Color(0xFFE08500);  // Orange 3D bevel
  static const Color duoOrangeLight = Color(0xFFFFE8D1); // Soft flame pill background

  static const Color duoYellow = Color(0xFFFFC800);      // Crowns, levels, podium gold 🏆
  static const Color duoYellowDark = Color(0xFFE5A400);  // Gold 3D bevel
  static const Color duoYellowLight = Color(0xFFFFF7D6); // Soft crown pill background

  static const Color duoRed = Color(0xFFFF4B4B);         // Warnings / high-footprint alerts
  static const Color duoRedDark = Color(0xFFD92525);

  static const Color duoGray = Color(0xFFE5E5E5);        // 2px borders, locked node path
  static const Color duoGrayDark = Color(0xFFAFAFAF);    // Locked icons & subtitles
  static const Color duoGrayLight = Color(0xFFF7F7F7);   // Page background / locked fills

  static const Color duoText = Color(0xFF3C3C3C);        // Charcoal high-contrast text
  static const Color duoSubtext = Color(0xFF777777);     // Secondary gray text

  // Backwards-compatible aliases mapping to Duolingo palette
  static const Color primaryGreen = duoGreen;
  static const Color accentGreen = duoGreenDark;
  static const Color lightGreen = duoGreenLight;
  static const Color surfaceColor = Colors.white;
  static const Color darkText = duoText;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: duoGreen,
        primary: duoGreen,
        secondary: duoBlue,
        tertiary: duoOrange,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: duoText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: duoText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: duoGray, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: duoGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: duoGray,
        thickness: 2,
        space: 1,
      ),
    );
  }
}
