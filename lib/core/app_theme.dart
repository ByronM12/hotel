import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // LUXURY COLOR PALETTE 
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkCharcoal = Color(0xFF1A1A1A);
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2C3E50);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    colorScheme: const ColorScheme.light(
      primary: darkCharcoal,
      secondary: accentGold,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      // Grand titles (magazine-style)
      displayLarge: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w800,
        fontSize: 42,
        fontFamily: 'Montserrat',
        height: 1,
      ),
      displayMedium: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        fontFamily: 'Montserrat',
      ),
      // Headers
      headlineMedium: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        fontFamily: 'Montserrat',
      ),
      headlineSmall: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        fontFamily: 'Montserrat',
      ),
      // Card titles
      titleLarge: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        fontFamily: 'Montserrat',
      ),
      titleMedium: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        fontFamily: 'Montserrat',
      ),
      titleSmall: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        fontFamily: 'Montserrat',
      ),
      // Body text
      bodyLarge: TextStyle(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Montserrat',
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF666666),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Montserrat',
      ),
      bodySmall: TextStyle(
        color: Color(0xFF888888),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Montserrat',
      ),
      // Labels & captions
      labelMedium: TextStyle(
        color: Color(0xFF999999),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
      ),
    ),
  );
}
