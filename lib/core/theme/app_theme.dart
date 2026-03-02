import 'package:flutter/material.dart';

class AppTheme {
  //Colors

  static const Color primary = Color(0xFFFD802E);
  static const Color secondary = Color(0xFF233D4C);
  static const Color background = Color(0xFFF5F7FA);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Principal colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
    ),
    scaffoldBackgroundColor: background,
    //Global fonts
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    //Global buttom styles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    //Inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
