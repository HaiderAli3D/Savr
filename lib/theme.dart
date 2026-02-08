import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Theme - True Black Background
  static const background = Color(0xFF000000); // True black
  static const surface = Color(0xFF121212); // Very dark gray for cards
  static const surfaceVariant = Color(0xFF1E1E1E); // Slightly lighter
  
  // Primary Brand Colors - Vibrant Blue
  static const primary = Color(0xFF5B8EF4); // HSL(230, 85%, 60%)
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1E3A8A);
  static const onPrimaryContainer = Color(0xFFBFDBFE);

  // Accent - Green for Savings
  static const accent = Color(0xFF34D399); // HSL(145, 65%, 48%)
  static const onAccent = Color(0xFF000000);
  static const accentContainer = Color(0xFF1A3E31);
  static const onAccentContainer = Color(0xFFD1FAE5);
  
  // Secondary - Purple accent
  static const secondary = Color(0xFFA78BFA); // HSL(260, 60%, 58%)
  static const onSecondary = Color(0xFFFFFFFF);

  // Text Colors
  static const textPrimary = Color(0xFFF2F2F2); // 95% white
  static const textSecondary = Color(0xFF737373); // 45% gray
  static const textTertiary = Color(0xFF525252); // 32% gray
  
  // Borders & Dividers
  static const border = Color(0xFF242424); // 14% white
  static const divider = Color(0xFF1F1F1F);
  
  // Specific UI Colors
  static const moneySaved = Color(0xFF10B981); // Emerald for savings
  static const moneyLost = Color(0xFFEF4444); // Red for losses
  static const warning = Color(0xFFF59E0B); // Amber
  
  // Muted backgrounds
  static const muted = Color(0xFF1F1F1F);
  static const mutedForeground = Color(0xFF737373);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const EdgeInsets page = EdgeInsets.all(20.0);
  static const EdgeInsets card = EdgeInsets.all(16.0);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double pill = 100.0;
}

// Using dark theme by default for the modern look
final ThemeData darkTheme = _buildDarkTheme();
final ThemeData lightTheme = darkTheme; // Using dark theme for both

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.moneyLost,
      onError: Colors.white,
      tertiary: AppColors.accent,
      onTertiary: AppColors.onAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 1.5,
      ),
    ),
  );
}
