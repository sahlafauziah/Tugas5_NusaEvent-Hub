import 'package:flutter/material.dart';

/// Palet warna ungu-pink soft NusaEvent Hub.
class AppColors {
  AppColors._();

  static const Color purple = Color(0xFF8E6FD8);
  static const Color purpleDeep = Color(0xFF5B3FA6);
  static const Color lavender = Color(0xFFF0E9FC);
  static const Color pink = Color(0xFFE58BBB);
  static const Color pinkDeep = Color(0xFFB8457F);
  static const Color pinkSoft = Color(0xFFFDE6F1);
  static const Color background = Color(0xFFFBF7FF);
  static const Color outline = Color(0xFFE5DAF6);
  static const Color shadow = Color(0x4D8E6FD8);

  /// Gradient utama (header, indikator langkah, aksen tiket).
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9A7EE3), Color(0xFFE48DC2)],
  );

  /// Gradient lembut untuk kartu ringkasan.
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0E9FC), Color(0xFFFDE6F1)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.purple,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lavender,
      onPrimaryContainer: AppColors.purpleDeep,
      secondary: AppColors.pink,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.pinkSoft,
      onSecondaryContainer: const Color(0xFF6E1F4B),
      tertiaryContainer: const Color(0xFFE8E6FB),
      onTertiaryContainer: AppColors.purpleDeep,
      errorContainer: const Color(0xFFFFE0E8),
      onErrorContainer: const Color(0xFF8C1D3F),
      outlineVariant: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.purple, width: 1.5)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.purpleDeep,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.lavender,
        checkmarkColor: AppColors.purpleDeep,
        side: BorderSide(color: AppColors.outline),
        shape: StadiumBorder(),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
