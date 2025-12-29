// =============================================================================
// FILE: app_text_styles.dart
// PURPOSE: Typography system for WatchHub luxury watch application
// DESCRIPTION: Defines text styles using Google Fonts with Playfair Display
//              for headings (luxury serif) and Inter for body text (modern sans).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for WatchHub
///
/// Design Philosophy:
/// - Playfair Display for headings (luxury, editorial feel)
/// - Inter for body text (clean, modern, highly readable)
/// - Consistent sizing scale based on Material Design
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ===========================================================================
  // FONT FAMILIES
  // ===========================================================================

  /// Luxury serif font for headings and display text
  static String get headingFontFamily =>
      GoogleFonts.playfairDisplay().fontFamily!;

  /// Modern sans-serif for body text
  static String get bodyFontFamily => GoogleFonts.inter().fontFamily!;

  // ===========================================================================
  // DISPLAY STYLES - Large headlines
  // ===========================================================================

  /// Display Large - App name, hero sections
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  /// Display Medium - Section headers
  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  /// Display Small - Subsection headers
  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // ===========================================================================
  // HEADLINE STYLES - Page titles
  // ===========================================================================

  /// Headline Large - Page titles
  static TextStyle headlineLarge = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  /// Headline Medium - Section titles
  static TextStyle headlineMedium = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  /// Headline Small - Subsection titles
  static TextStyle headlineSmall = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // ===========================================================================
  // TITLE STYLES - Component titles
  // ===========================================================================

  /// Title Large - Card titles, dialog titles
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  /// Title Medium - List item titles
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  /// Title Small - Small titles
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  // ===========================================================================
  // BODY STYLES - Main content
  // ===========================================================================

  /// Body Large - Primary body text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - Secondary body text
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
    height: 1.5,
  );

  /// Body Small - Captions, helper text
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.4,
    height: 1.4,
  );

  // ===========================================================================
  // LABEL STYLES - Buttons, inputs
  // ===========================================================================

  /// Label Large - Primary buttons
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  /// Label Medium - Secondary buttons
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Label Small - Badges, chips
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ===========================================================================
  // SPECIAL STYLES
  // ===========================================================================

  /// Price display - Large gold price
  static TextStyle priceDisplay = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryGold,
    letterSpacing: -0.5,
  );

  /// Price small - Compact price display
  static TextStyle priceSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryGold,
  );

  /// Brand name - Watch brand display
  static TextStyle brandName = GoogleFonts.playfairDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryGold,
    letterSpacing: 2,
  );

  /// Product name - Watch model name
  static TextStyle productName = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// App bar title
  static TextStyle appBarTitle = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );

  /// Button text with gold color
  static TextStyle goldButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.scaffoldBackground,
    letterSpacing: 1,
  );

  /// Error text
  static TextStyle error = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    letterSpacing: 0.4,
  );

  /// Success text
  static TextStyle success = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    letterSpacing: 0.4,
  );

  /// Price Large - Large price display
  static TextStyle priceLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryGold,
    letterSpacing: -0.5,
  );

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply gold color to any text style
  static TextStyle withGold(TextStyle style) {
    return style.copyWith(color: AppColors.primaryGold);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
