import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark(Color accent) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: const Color(0xFF0A0A0B),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      cardColor: Colors.white.withOpacity(0.05),
      dividerColor: Colors.white.withOpacity(0.08),
      useMaterial3: true,
    );
  }

  static ThemeData light(Color accent) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: accent,
        surface: const Color(0xFFF5F5F7),
        onSurface: const Color(0xFF1A1A1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1E),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.black.withOpacity(0.08),
      useMaterial3: true,
    );
  }
}