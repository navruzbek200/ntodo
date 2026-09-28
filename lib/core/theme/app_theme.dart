import 'package:flutter/material.dart';

/// Brand palette – matches the launcher icon.
class AppPalette {
  static const brand = Color(0xFF4A3780);
  static const brandLight = Color(0xFF6B55C4);
  static const brandDark = Color(0xFF2C1D5E);
  static const accent = Color(0xFFFFB547);
  static const background = Color(0xFFF5F3FB);
  static const ink = Color(0xFF1F1B2D);
  static const muted = Color(0xFF8A8599);
  static const line = Color(0xFFE7E3F3);
  static const danger = Color(0xFFE5484D);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandLight, brand, brandDark],
  );
}

class AppTheme {
  static const Color primaryColor = AppPalette.brand;

  static final ThemeData lightTheme = _build();

  static ThemeData _build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.brand,
      primary: AppPalette.brand,
      secondary: AppPalette.accent,
      surface: Colors.white,
      error: AppPalette.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: scheme,
      primaryColor: AppPalette.brand,
      scaffoldBackgroundColor: AppPalette.background,
    );

    final radius16 = BorderRadius.circular(16);

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppPalette.ink,
        displayColor: AppPalette.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.brand,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.brand,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.background,
        hintStyle: const TextStyle(color: AppPalette.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: const BorderSide(color: AppPalette.brand, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.ink,
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
        actionTextColor: AppPalette.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppPalette.brand),
    );
  }
}
