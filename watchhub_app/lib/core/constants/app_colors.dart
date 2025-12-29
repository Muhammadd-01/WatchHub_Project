// =============================================================================
// FILE: app_colors.dart
// PURPOSE: Premium color palette for WatchHub luxury watch application
// DESCRIPTION: Defines a sophisticated dark theme with gold and silver accents
//              to reflect the luxury nature of the watch shopping experience.
// =============================================================================

import 'package:flutter/material.dart';

/// Premium color palette for WatchHub
///
/// Design Philosophy:
/// - Dark mode first for luxury feel
/// - Gold accents for premium emphasis
/// - Silver accents for secondary elements
/// - Glassmorphism-compatible colors with opacity
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===========================================================================
  // PRIMARY COLORS - GOLD PALETTE
  // ===========================================================================
  // Gold represents luxury, success, and premium quality

  /// Primary gold color - main accent
  static const Color primaryGold = Color(0xFFD4AF37);

  /// Darker gold for pressed states
  static const Color darkGold = Color(0xFFB8860B);

  /// Lighter gold for highlights
  static const Color lightGold = Color(0xFFE6C97A);

  /// Very light gold for subtle accents
  static const Color paleGold = Color(0xFFF5E6C8);

  // ===========================================================================
  // SECONDARY COLORS - SILVER PALETTE
  // ===========================================================================
  // Silver represents elegance and sophistication

  /// Primary silver color
  static const Color primarySilver = Color(0xFFC0C0C0);

  /// Darker silver for depth
  static const Color darkSilver = Color(0xFF808080);

  /// Light silver for subtle elements
  static const Color lightSilver = Color(0xFFE8E8E8);

  // ===========================================================================
  // BACKGROUND COLORS - DARK THEME
  // ===========================================================================

  /// Main scaffold background - near black
  static const Color scaffoldBackground = Color(0xFF0A0A0A);

  /// Card background - slightly lighter
  static const Color cardBackground = Color(0xFF1A1A1A);

  /// Surface color for elevated elements
  static const Color surfaceColor = Color(0xFF242424);

  /// Slightly elevated surface
  static const Color elevatedSurface = Color(0xFF2A2A2A);

  /// Dialog/modal background
  static const Color dialogBackground = Color(0xFF1E1E1E);

  // ===========================================================================
  // GLASSMORPHISM COLORS
  // ===========================================================================
  // Semi-transparent colors for glass effect

  /// Glass background with low opacity
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);

  /// Glass border color
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);

  /// Glass shadow
  static Color glassShadow = Colors.black.withValues(alpha: 0.3);

  /// Dark glass for overlays
  static Color darkGlass = const Color(0xFF1A1A1A).withValues(alpha: 0.7);

  // ===========================================================================
  // LIGHT THEME COLORS
  // ===========================================================================
  static const Color scaffoldBackgroundLight = Color(0xFFF8F9FA); // Off-white
  static const Color cardBackgroundLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondaryLight = Color(0xFF6C757D); // Grey
  static const Color textTertiaryLight = Color(0xFFADB5BD); // Light grey
  static const Color textHintLight = Color(0xFFCED4DA);
  static const Color iconPrimaryLight = Color(0xFF212529);
  static const Color iconSecondaryLight = Color(0xFF6C757D);
  static const Color dividerLight = Color(0xFFE9ECEF);
  static const Color cardBorderLight = Color(0xFFDEE2E6);
  static const Color inputBorderLight = Color(0xFFDEE2E6);

  // ===========================================================================
  // TEXT COLORS
  // ===========================================================================

  /// Primary text - white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - light gray
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// Tertiary text - darker gray
  static const Color textTertiary = Color(0xFF707070);

  /// Disabled text
  static const Color textDisabled = Color(0xFF505050);

  /// Hint text color
  static const Color textHint = Color(0xFF606060);

  // ===========================================================================
  // STATUS COLORS
  // ===========================================================================

  /// Success color - muted green
  static const Color success = Color(0xFF4CAF50);

  /// Error color - muted red
  static const Color error = Color(0xFFE57373);

  /// Warning color - amber
  static const Color warning = Color(0xFFFFB74D);

  /// Info color - blue
  static const Color info = Color(0xFF64B5F6);

  // ===========================================================================
  // GRADIENT DEFINITIONS
  // ===========================================================================

  /// Premium gold gradient for buttons and highlights
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGold, primaryGold, darkGold],
  );

  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
  );

  /// Card gradient for glass effect
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.1),
      Colors.white.withValues(alpha: 0.05)
    ],
  );

  /// Shimmer gradient for loading states
  static LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, surfaceColor, cardBackground],
  );

  // ===========================================================================
  // BORDER COLORS
  // ===========================================================================

  /// Subtle border for cards
  static Color cardBorder = Colors.white.withValues(alpha: 0.08);

  /// Input field border
  static const Color inputBorder = Color(0xFF3A3A3A);

  /// Focused input border
  static const Color inputFocusedBorder = primaryGold;

  /// Divider color
  static const Color divider = Color(0xFF2A2A2A);

  // ===========================================================================
  // ICON COLORS
  // ===========================================================================

  /// Primary icon color
  static const Color iconPrimary = Color(0xFFE0E0E0);

  /// Secondary icon color
  static const Color iconSecondary = Color(0xFF808080);

  /// Accent icon color (gold)
  static const Color iconAccent = primaryGold;

  // ===========================================================================
  // RATING COLORS
  // ===========================================================================

  /// Star rating color (gold)
  static const Color ratingColor = primaryGold;

  /// Empty star color
  static const Color ratingEmpty = Color(0xFF404040);

  // ===========================================================================
  // MATERIAL COLOR SWATCH
  // ===========================================================================

  /// Primary swatch for Material widgets
  static const MaterialColor primarySwatch =
      MaterialColor(0xFFD4AF37, <int, Color>{
    50: Color(0xFFFBF7E9),
    100: Color(0xFFF5E6C8),
    200: Color(0xFFEED5A5),
    300: Color(0xFFE6C482),
    400: Color(0xFFDEB968),
    500: Color(0xFFD4AF37),
    600: Color(0xFFC9A02F),
    700: Color(0xFFBC8F27),
    800: Color(0xFFAE7F1F),
    900: Color(0xFF946512),
  });
}
