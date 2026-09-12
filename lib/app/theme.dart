import 'package:flutter/material.dart';

/// EcoLoop visual theme configuration.
/// Uses nature-inspired green and earth tones reflecting circular sustainability.
class AppTheme {
  AppTheme._();

  // Primary brand colors
  static const Color primaryGreen = Color(0xFF1B5E20); // Forest green
  static const Color accentGreen = Color(0xFF4CAF50);  // Fresh green
  static const Color lightGreen = Color(0xFFE8F5E9);   // Mint / background tint
  static const Color surfaceColor = Color(0xFFF9FBE7); // Light earth tone
  static const Color darkText = Color(0xFF1A1C18);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGreen,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9F6),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
