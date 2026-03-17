import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6C9BD2); // soft blue
  static const Color secondaryColor = Color(0xFFA8D5BA); // soft mint
  static const Color accentColor = Color(0xFFFFB6B9); // soft pink
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D4059);
  static const Color textSecondary = Color(0xFF6B7A8F);
  static const Color calmUrgeRed = Color(0xFFFF5252); // For the center button

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Poppins',

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: calmUrgeRed,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent, // Prevents color change on scroll
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceColor,
      shadowColor: Colors.grey.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: calmUrgeRed,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}
