// =============================================================================
// FILE: admin_theme.dart
// PURPOSE: Theme configuration for Admin Panel
// DESCRIPTION: Dynamic theme supporting Dark and Light modes, synced with AppTheme.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Admin Panel Theme Configuration
class AdminTheme {
  AdminTheme._();

  // ===========================================================================
  // MAIN THEME DATA
  // ===========================================================================

  /// The main dark theme for the admin panel
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorSchemeDark,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      primaryColor: AppColors.primaryGold,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      iconTheme: _iconTheme,
      dividerTheme: _dividerTheme,
      listTileTheme: _listTileTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// The main light theme for the admin panel
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorSchemeLight,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLight,
      primaryColor: AppColors.primaryGold,
      textTheme: _textThemeLight,
      appBarTheme: _appBarThemeLight,
      cardTheme: _cardThemeLight,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationThemeLight,
      iconTheme: _iconThemeLight,
      dividerTheme: _dividerThemeLight,
      listTileTheme: _listTileThemeLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ===========================================================================
  // COLOR SCHEMES
  // ===========================================================================

  static ColorScheme get _colorSchemeDark {
    return ColorScheme.dark(
      primary: AppColors.primaryGold,
      onPrimary: Colors.black,
      primaryContainer: AppColors.darkGold,
      onPrimaryContainer: AppColors.paleGold,
      secondary: AppColors.primarySilver,
      onSecondary: Colors.black,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.black,
      outline: AppColors.inputBorder,
    );
  }

  static ColorScheme get _colorSchemeLight {
    return ColorScheme.light(
      primary: AppColors.primaryGold,
      onPrimary: Colors.white,
      primaryContainer: AppColors.paleGold,
      onPrimaryContainer: AppColors.darkGold,
      secondary: AppColors.primarySilver,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.inputBorderLight,
    );
  }

  // ===========================================================================
  // TEXT THEMES
  // ===========================================================================

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary),
      titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary),
      bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary),
      labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary),
    );
  }

  static TextTheme get _textThemeLight {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight),
      displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight),
      displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight),
      titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryLight),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight),
      bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryLight),
      labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryLight),
    );
  }

  // ===========================================================================
  // COMPONENT THEMES (DARK)
  // ===========================================================================

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.scaffoldBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.iconPrimary, size: 24),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.cardBackground,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.black,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGold, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
      labelStyle:
          GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
    );
  }

  static IconThemeData get _iconTheme {
    return const IconThemeData(color: AppColors.iconPrimary, size: 24);
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
        color: AppColors.divider, thickness: 1, space: 1);
  }

  static ListTileThemeData get _listTileTheme {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
      iconColor: AppColors.iconPrimary,
      textColor: AppColors.textPrimary,
    );
  }

  // ===========================================================================
  // COMPONENT THEMES (LIGHT)
  // ===========================================================================

  static AppBarTheme get _appBarThemeLight {
    return AppBarTheme(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        letterSpacing: 1,
      ),
      iconTheme:
          const IconThemeData(color: AppColors.iconPrimaryLight, size: 24),
    );
  }

  static CardThemeData get _cardThemeLight {
    return CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorderLight, width: 1),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  static InputDecorationTheme get _inputDecorationThemeLight {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGold, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
      labelStyle:
          GoogleFonts.inter(color: AppColors.textSecondaryLight, fontSize: 14),
      hintStyle:
          GoogleFonts.inter(color: AppColors.textHintLight, fontSize: 14),
    );
  }

  static IconThemeData get _iconThemeLight {
    return const IconThemeData(color: AppColors.iconPrimaryLight, size: 24);
  }

  static DividerThemeData get _dividerThemeLight {
    return const DividerThemeData(
        color: AppColors.dividerLight, thickness: 1, space: 1);
  }

  static ListTileThemeData get _listTileThemeLight {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
      iconColor: AppColors.iconPrimaryLight,
      textColor: AppColors.textPrimaryLight,
    );
  }
}
