import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SAVR Design System - Lovable-inspired fintech dark theme
class AppColors {
  // Background & Surfaces (matching HSL values exactly)
  static const background = Color(0xFF0B0B10); // Near-black with hint of purple
  static const backgroundPure = Color(0xFF000000); // True black for cards
  static const foreground = Color(0xFFF2F2F2); // hsl(0 0% 95%)
  
  static const card = Color(0xFF121212); // hsl(0 0% 7%)
  static const cardForeground = Color(0xFFF2F2F2); // hsl(0 0% 95%)
  
  static const surface = Color(0xFF121212); // hsl(0 0% 7%)
  static const surfaceVariant = Color(0xFF1F1F1F); // hsl(0 0% 12%)
  static const surfaceHover = Color(0xFF252525); // Hover state
  
  // Primary (Purple gradient) - Core brand color
  static const primary = Color(0xFF8B5CF6); // hsl(262 83% 66%)
  static const primaryDark = Color(0xFF7C3AED); // hsl(262 83% 58%)
  static const primaryLight = Color(0xFFA78BFA); // hsl(262 83% 76%)
  static const primaryForeground = Color(0xFFFFFFFF);
  
  // Secondary (Blue accent) - hsl(230 85% 60%)
  static const secondary = Color(0xFF3D5AFE);
  static const secondaryForeground = Color(0xFFFFFFFF);
  
  // Accent (Green for savings) - hsl(145 65% 48%)
  static const accent = Color(0xFF2BA564);
  static const accentForeground = Color(0xFF000000);
  
  // Muted colors
  static const muted = Color(0xFF1F1F1F); // hsl(0 0% 12%)
  static const mutedForeground = Color(0xFF737373); // hsl(0 0% 45%)
  
  // Border - hsl(0 0% 14%)
  static const border = Color(0xFF242424);
  static const borderLight = Color(0xFF2A2A2A);
  
  // Text colors
  static const textPrimary = Color(0xFFF2F2F2); // hsl(0 0% 95%)
  static const textSecondary = Color(0xFF9CA3AF); // hsl(220 9% 65%)
  static const textTertiary = Color(0xFF6B7280); // hsl(220 9% 46%)
  static const textMuted = Color(0xFF525252); // Darker muted
  
  // Status colors
  static const success = Color(0xFF10B981); // hsl(145 65% 48%)
  static const successDark = Color(0xFF2BA564);
  static const error = Color(0xFFEF4444); // hsl(0 72% 60%)
  static const warning = Color(0xFFF59E0B); // hsl(38 92% 50%)
  static const info = Color(0xFF3B82F6); // hsl(221 83% 60%)
  
  // Savings badge
  static const savingsBadgeBg = Color(0x1A2BA564); // accent with 10% opacity
  static const savingsBadgeText = Color(0xFF2BA564);
  
  // Gradients
  static const purpleGradientStart = Color(0xFF8B5CF6);
  static const purpleGradientEnd = Color(0xFF7C3AED);
  
  // Glass morphism
  static const glassBg = Color(0x14FFFFFF); // 8% white
  static const glassStroke = Color(0x29FFFFFF); // 16% white
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  static const EdgeInsets page = EdgeInsets.all(20.0);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets card = EdgeInsets.all(16.0);
  static const EdgeInsets cardCompact = EdgeInsets.all(12.0);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 100.0;
}

class AppShadows {
  // Soft glow for cards
  static List<BoxShadow> cardGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Stronger glow for hero elements
  static List<BoxShadow> heroGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Green glow for savings
  static List<BoxShadow> savingsGlow = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];
}

// Always use dark theme to match the React app
final ThemeData appTheme = _buildDarkTheme();

ThemeData _buildDarkTheme() {
  final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outline: AppColors.border,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 64,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: TextTheme(
      // Display - Hero savings numbers (48px)
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -2,
        height: 1.0,
      ),
      // Display Medium - Large counters (36px)
      displayMedium: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.0,
      ),
      // Headline Large - Page titles (24px)
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      // Headline Medium - Section headers (18px)
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      // Title Large - Card titles (16px)
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
      // Title Medium - Smaller card titles (14px)
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
      // Title Small - Section labels (uppercase) (11px)
      titleSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedForeground,
        letterSpacing: 1.5,
      ),
      // Body Large - Main text (15px)
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      // Body Medium - Secondary text (14px)
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      // Body Small - Tertiary text (12px)
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.4,
      ),
      // Label Large - Button text (14px)
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      // Label Medium - Small buttons (12px)
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
      // Label Small - Tiny labels (10px)
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    ),
  );
}
