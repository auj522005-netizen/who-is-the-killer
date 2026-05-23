import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ────────────────────────────────────────────────────────────────
/// AppTheme — Structured Rebellion Design System
///
/// A modern, hyper-clean Swiss-style minimalist layout with
/// high-contrast solid pitch-black backgrounds, neon accent
/// colors, and bold heavy typography.
/// ────────────────────────────────────────────────────────────────
abstract class AppTheme {
  /// The main application theme data
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonOrange,
          secondary: AppColors.neonGreen,
          surface: AppColors.surface,
          error: AppColors.neonRed,
          onPrimary: AppColors.textOnAccent,
          onSecondary: AppColors.textOnAccent,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
          iconTheme: const IconThemeData(color: AppColors.neonOrange),
        ),
        textTheme: TextTheme(
          /// Display Large — Used for game titles, splash screens
          displayLarge: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 40,
            color: AppColors.textPrimary,
            letterSpacing: -1.5,
            height: 1.1,
          ),

          /// Display Medium — Section headers
          displayMedium: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),

          /// Display Small — Card titles
          displaySmall: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppColors.textPrimary,
            letterSpacing: 0,
            height: 1.2,
          ),

          /// Headline Large — Player names
          headlineLarge: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),

          /// Headline Medium — Clue titles
          headlineMedium: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
            letterSpacing: 0.25,
          ),

          /// Headline Small — Phase labels
          headlineSmall: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.neonOrange,
            letterSpacing: 0.5,
          ),

          /// Body Large — Main game text, clues content
          bodyLarge: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: AppColors.textPrimary,
            letterSpacing: 0.15,
            height: 1.6,
          ),

          /// Body Medium — Player alibis, chat messages
          bodyMedium: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 0.25,
            height: 1.5,
          ),

          /// Body Small — Timers, subtle info
          bodySmall: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.textDisabled,
            letterSpacing: 0.4,
            height: 1.4,
          ),

          /// Label Large — Button text
          labelLarge: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.textOnAccent,
            letterSpacing: 1.25,
          ),

          /// Label Medium — Chip labels, tags
          labelMedium: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.neonOrange,
            letterSpacing: 0.5,
          ),

          /// Label Small — Badge text
          labelSmall: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonOrange,
            foregroundColor: AppColors.textOnAccent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: GoogleFonts.notoSansArabic(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neonOrange,
            side: const BorderSide(color: AppColors.neonOrange, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: GoogleFonts.notoSansArabic(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceElevated,
          selectedColor: AppColors.neonOrange,
          labelStyle: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.neonOrange, width: 1),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
