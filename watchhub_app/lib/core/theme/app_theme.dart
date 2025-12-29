// =============================================================================
// FILE: app_theme.dart
// PURPOSE: Complete Material 3 theme configuration for WatchHub
// DESCRIPTION: Defines a premium dark theme with custom component themes,
//              ensuring consistent luxury styling across the entire app.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Premium dark theme for WatchHub
///
/// This theme provides:
/// - Dark mode optimized for luxury feel
/// - Gold accent colors for premium elements
/// - Custom component themes for consistency
/// - Glassmorphism-ready styling
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ===========================================================================
  // MAIN THEME DATA
  // ===========================================================================

  /// The main light theme for the application
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
      elevatedButtonTheme:
          _elevatedButtonTheme, // Reuse (customized internally if needed)
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationThemeLight,
      bottomNavigationBarTheme: _bottomNavigationBarThemeLight,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      iconTheme: _iconThemeLight,
      dividerTheme: _dividerThemeLight,
      dialogTheme: _dialogThemeLight,
      snackBarTheme: _snackBarThemeLight,
      chipTheme: _chipThemeLight,
      bottomSheetTheme: _bottomSheetThemeLight,
      listTileTheme: _listTileThemeLight,
      tabBarTheme: _tabBarThemeLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashColor: AppColors.primaryGold.withOpacity(0.1),
      highlightColor: AppColors.primaryGold.withOpacity(0.05),
    );
  }

  /// The main dark theme for the application
  static ThemeData get darkTheme {
    return ThemeData(
      // Use Material 3 design system
      useMaterial3: true,

      // Dark brightness
      brightness: Brightness.dark,

      // Primary color scheme
      colorScheme: _colorScheme,

      // Background colors
      scaffoldBackgroundColor: AppColors.scaffoldBackground,

      // Primary swatch
      primaryColor: AppColors.primaryGold,

      // Typography
      textTheme: _textTheme,

      // Component themes
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      iconTheme: _iconTheme,
      dividerTheme: _dividerTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      chipTheme: _chipTheme,
      bottomSheetTheme: _bottomSheetTheme,
      listTileTheme: _listTileTheme,
      tabBarTheme: _tabBarTheme,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Splash and highlight
      splashColor: AppColors.primaryGold.withOpacity(0.1),
      highlightColor: AppColors.primaryGold.withOpacity(0.05),
    );
  }

  // ===========================================================================
  // COLOR SCHEME
  // ===========================================================================

  static ColorScheme get _colorScheme {
    return ColorScheme.dark(
      primary: AppColors.primaryGold,
      onPrimary: AppColors.scaffoldBackground,
      primaryContainer: AppColors.darkGold,
      onPrimaryContainer: AppColors.paleGold,
      secondary: AppColors.primarySilver,
      onSecondary: AppColors.scaffoldBackground,
      secondaryContainer: AppColors.darkSilver,
      onSecondaryContainer: AppColors.lightSilver,
      tertiary: AppColors.lightGold,
      onTertiary: AppColors.scaffoldBackground,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.2),
      onErrorContainer: AppColors.error,
      surface: AppColors.surfaceColor,
      onSurface: AppColors.textPrimary,
      outline: AppColors.inputBorder,
      outlineVariant: AppColors.divider,
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
      secondaryContainer: AppColors.lightSilver,
      onSecondaryContainer: AppColors.darkSilver,
      tertiary: AppColors.lightGold,
      onTertiary: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,
      surface: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      outline: AppColors.inputBorderLight,
      outlineVariant: AppColors.dividerLight,
    );
  }

  // ===========================================================================
  // TEXT THEME
  // ===========================================================================

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

  static TextTheme get _textTheme {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      // Headlines
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),

      // Titles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ),

      // Labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ===========================================================================
  // APP BAR THEME
  // ===========================================================================

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.scaffoldBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.iconPrimary, size: 24),
      actionsIconTheme: const IconThemeData(
        color: AppColors.primaryGold,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // ===========================================================================
  // CARD THEME
  // ===========================================================================

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    );
  }

  // ===========================================================================
  // ELEVATED BUTTON THEME
  // ===========================================================================

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.black.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.black.withOpacity(0.05);
          }
          return null;
        }),
      ),
    );
  }

  // ===========================================================================
  // OUTLINED BUTTON THEME
  // ===========================================================================

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT BUTTON THEME
  // ===========================================================================

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ===========================================================================
  // INPUT DECORATION THEME
  // ===========================================================================

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
      errorStyle: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
      prefixIconColor: AppColors.iconSecondary,
      suffixIconColor: AppColors.iconSecondary,
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR THEME
  // ===========================================================================

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.iconSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ===========================================================================
  // FLOATING ACTION BUTTON THEME
  // ===========================================================================

  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.scaffoldBackground,
      elevation: 4,
      shape: CircleBorder(),
    );
  }

  // ===========================================================================
  // ICON THEME
  // ===========================================================================

  static IconThemeData get _iconTheme {
    return const IconThemeData(color: AppColors.iconPrimary, size: 24);
  }

  // ===========================================================================
  // DIVIDER THEME
  // ===========================================================================

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  // ===========================================================================
  // DIALOG THEME
  // ===========================================================================

  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: AppColors.dialogBackground,
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ===========================================================================
  // SNACKBAR THEME
  // ===========================================================================

  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.cardBackground,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    );
  }

  // ===========================================================================
  // CHIP THEME
  // ===========================================================================

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primaryGold.withOpacity(0.2),
      disabledColor: AppColors.surfaceColor,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryGold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.cardBorder),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET THEME
  // ===========================================================================

  static BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.cardBackground,
      modalBackgroundColor: AppColors.cardBackground,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  // ===========================================================================
  // LIST TILE THEME
  // ===========================================================================

  static ListTileThemeData get _listTileTheme {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
      iconColor: AppColors.iconPrimary,
      textColor: AppColors.textPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ===========================================================================
  // TAB BAR THEME
  // ===========================================================================

  static TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      labelColor: AppColors.primaryGold,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
      ),
      indicatorSize: TabBarIndicatorSize.label,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  // ===========================================================================
  // LIGHT THEME COMPONENTS
  // ===========================================================================

  static AppBarTheme get _appBarThemeLight {
    return AppBarTheme(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        letterSpacing: 1,
      ),
      iconTheme:
          const IconThemeData(color: AppColors.iconPrimaryLight, size: 24),
      actionsIconTheme:
          const IconThemeData(color: AppColors.primaryGold, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
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
      clipBehavior: Clip.antiAlias,
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

  static BottomNavigationBarThemeData get _bottomNavigationBarThemeLight {
    return BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.iconSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static IconThemeData get _iconThemeLight {
    return const IconThemeData(color: AppColors.iconPrimaryLight, size: 24);
  }

  static DividerThemeData get _dividerThemeLight {
    return const DividerThemeData(
        color: AppColors.dividerLight, thickness: 1, space: 1);
  }

  static DialogThemeData get _dialogThemeLight {
    return DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight),
      contentTextStyle:
          GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight),
    );
  }

  static SnackBarThemeData get _snackBarThemeLight {
    return SnackBarThemeData(
      backgroundColor: AppColors.textPrimaryLight,
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    );
  }

  static ChipThemeData get _chipThemeLight {
    return ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryGold.withOpacity(0.2),
      disabledColor: Colors.grey[200],
      labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.cardBorderLight),
      ),
    );
  }

  static BottomSheetThemeData get _bottomSheetThemeLight {
    return const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      elevation: 16,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    );
  }

  static ListTileThemeData get _listTileThemeLight {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
      iconColor: AppColors.iconPrimaryLight,
      textColor: AppColors.textPrimaryLight,
    );
  }

  static TabBarThemeData get _tabBarThemeLight {
    return TabBarThemeData(
      labelColor: AppColors.primaryGold,
      unselectedLabelColor: AppColors.textSecondaryLight,
      labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2)),
    );
  }

  /// Configure system UI overlay style for the app
  static void setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.scaffoldBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
