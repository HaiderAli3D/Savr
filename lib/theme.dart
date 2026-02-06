import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Brand Colors (Deep Navy / Slate)
  static const primary = Color(0xFF0F172A); // Slate 900
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE2E8F0); // Slate 200
  static const onPrimaryContainer = Color(0xFF1E293B); // Slate 800

  // Secondary/Accent (Emerald Green for Savings)
  static const secondary = Color(0xFF10B981); // Emerald 500
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD1FAE5); // Emerald 100
  static const onSecondaryContainer = Color(0xFF065F46); // Emerald 800

  // Backgrounds
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  
  // Specific UI Colors
  static const moneySaved = Color(0xFF059669); // Emerald 600
  static const moneyLost = Color(0xFFDC2626); // Red 600
  static const warning = Color(0xFFF59E0B); // Amber 500

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textTertiary = Color(0xFF94A3B8); // Slate 400
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

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  
  // Base colors
  final bg = isDark ? const Color(0xFF0F172A) : AppColors.background;
  final surface = isDark ? const Color(0xFF1E293B) : AppColors.surface;
  final txt = isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
  
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: AppColors.primary, // Keeping branding consistent
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
      onError: Colors.white,
      surface: surface,
      onSurface: txt,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txt),
      titleTextStyle: GoogleFonts.poppins(
        color: txt,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF334155) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: txt,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: txt,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: txt,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: txt,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: txt,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
        height: 1.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? const Color(0xFF64748B) : AppColors.textTertiary,
        letterSpacing: 0.5,
      ),
    ),
  );
}
