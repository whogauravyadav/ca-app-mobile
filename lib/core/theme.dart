import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  /// Brand primary
  static const Color primary = Color(0xFF92A8FE);
  /// Darker companion for gradients / app bars / readable fills
  static const Color primaryDark = Color(0xFF6B86F0);
  /// Text / icons on top of primary fills
  static const Color onPrimary = Color(0xFF1A2340);

  static const Color accent = Color(0xFFFFB300);
  static const Color surface = Color(0xFFF4F7FF);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE4E9F5);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.accent,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary, height: 1.45),
      bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.surface,
      dividerColor: AppColors.border,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        disabledColor: AppColors.border,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.border),
        checkmarkColor: AppColors.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.45),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.7),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primary, width: 1.6),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.primaryDark,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        height: 70,
        indicatorColor: AppColors.primary.withOpacity(0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
        circularTrackColor: Color(0xFFE8EEFF),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      refreshIndicatorTheme: const RefreshIndicatorThemeData(
        color: AppColors.primaryDark,
        backgroundColor: Colors.white,
      ),
    );
  }
}
