import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5B4DB7);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
