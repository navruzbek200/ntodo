import 'package:flutter/material.dart';

/// Fixed brand colours (same in light and dark) – match the launcher icon.
class AppPalette {
  static const brand = Color(0xFF4A3780);
  static const brandLight = Color(0xFF6B55C4);
  static const brandDark = Color(0xFF2C1D5E);
  static const accent = Color(0xFFFFB547);
  static const danger = Color(0xFFE5484D);
}

/// Colours that change with the theme. Read with `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color background;
  final Color surface;
  final Color card;
  final Color cardBorder;
  final Color ink;
  final Color muted;
  final Color chip;
  final Color chipText;
  final Color checkIdle;
  final Color checkOn;
  final Color selectedFill;
  final Color shadow;
  final Color glass;
  final Color glassBorder;
  final Color orbA;
  final Color orbB;
  final Gradient headerGradient;

  const AppTokens({
    required this.background,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.ink,
    required this.muted,
    required this.chip,
    required this.chipText,
    required this.checkIdle,
    required this.checkOn,
    required this.selectedFill,
    required this.shadow,
    required this.glass,
    required this.glassBorder,
    required this.orbA,
    required this.orbB,
    required this.headerGradient,
  });

  static const light = AppTokens(
    background: Color(0xFFF5F3FB),
    surface: Colors.white,
    card: Color(0xE6FFFFFF),
    cardBorder: Color(0xFFEDE9F8),
    ink: Color(0xFF1F1B2D),
    muted: Color(0xFF7D778F),
    chip: Color(0xFFE9E4F7),
    chipText: AppPalette.brand,
    checkIdle: Color(0xFFC9BFE6),
    checkOn: AppPalette.brand,
    selectedFill: Color(0xFFF1EDFF),
    shadow: Color(0x142C1D5E),
    glass: Color(0x99FFFFFF),
    glassBorder: Color(0xB3FFFFFF),
    orbA: Color(0x407B61FF),
    orbB: Color(0x33FFB547),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppPalette.brandLight, AppPalette.brand, AppPalette.brandDark],
    ),
  );

  static const dark = AppTokens(
    background: Color(0xFF0E0A1C),
    surface: Color(0xFF1A1530),
    card: Color(0xCC1E1838),
    cardBorder: Color(0x14FFFFFF),
    ink: Color(0xFFF1EEFA),
    muted: Color(0xFFA29BBC),
    chip: Color(0xFF2B2350),
    chipText: Color(0xFFCBBFFF),
    checkIdle: Color(0xFF5A4F80),
    checkOn: Color(0xFF8B75F0),
    selectedFill: Color(0xFF2A2158),
    shadow: Color(0x66000000),
    glass: Color(0x8C1A1530),
    glassBorder: Color(0x1FFFFFFF),
    orbA: Color(0x597B61FF),
    orbB: Color(0x26FFB547),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4B39A0), Color(0xFF2E2168), Color(0xFF17102F)],
    ),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      card: c(card, other.card),
      cardBorder: c(cardBorder, other.cardBorder),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      chip: c(chip, other.chip),
      chipText: c(chipText, other.chipText),
      checkIdle: c(checkIdle, other.checkIdle),
      checkOn: c(checkOn, other.checkOn),
      selectedFill: c(selectedFill, other.selectedFill),
      shadow: c(shadow, other.shadow),
      glass: c(glass, other.glass),
      glassBorder: c(glassBorder, other.glassBorder),
      orbA: c(orbA, other.orbA),
      orbB: c(orbB, other.orbB),
      headerGradient: Gradient.lerp(headerGradient, other.headerGradient, t)!,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static final ThemeData lightTheme = _build(Brightness.light, AppTokens.light);
  static final ThemeData darkTheme = _build(Brightness.dark, AppTokens.dark);

  static ThemeData _build(Brightness brightness, AppTokens t) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppPalette.brandLight : AppPalette.brand;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.brand,
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: AppPalette.accent,
      surface: t.surface,
      onSurface: t.ink,
      error: AppPalette.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: t.background,
      extensions: [t],
    );

    final radius16 = BorderRadius.circular(16);
    const buttonText = TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16);

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: t.ink, displayColor: t.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? t.chipText : AppPalette.brand,
          textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        extendedTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0x14FFFFFF) : const Color(0xFFF3F0FA),
        hintStyle: TextStyle(color: t.muted),
        prefixIconColor: t.muted,
        suffixIconColor: t.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: t.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: t.checkOn, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: const BorderSide(color: AppPalette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: const BorderSide(color: AppPalette.danger, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2B2350) : t.ink,
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
        actionTextColor: AppPalette.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(fontFamily: 'Poppins', color: t.ink),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }
}
