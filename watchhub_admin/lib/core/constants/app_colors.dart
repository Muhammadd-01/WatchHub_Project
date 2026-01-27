// =============================================================================
// FILE: app_colors.dart
// PURPOSE: Premium color palette for WatchHub Admin Panel
// DESCRIPTION: Navy blue theme with cyan accents and metallic silver,
//              matching the main WatchHub app design.
// =============================================================================

import 'package:flutter/material.dart';

/// Premium color palette for WatchHub Admin
///
/// Design Philosophy:
/// - Navy blue base for sophisticated dark mode
/// - Cyan accents for modern, premium highlighting
/// - Metallic silver for secondary elements
/// - Glassmorphism-compatible colors with opacity
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===========================================================================
  // PRIMARY COLORS - CYAN PALETTE
  // ===========================================================================
  // Cyan represents innovation, technology, and premium quality

  /// Primary cyan color - main accent
  static const Color primaryCyan = Color(0xFF00A3FF);

  /// Darker cyan for pressed states
  static const Color darkCyan = Color(0xFF0088DD);

  /// Lighter cyan for highlights
  static const Color lightCyan = Color(0xFF66C7FF);

  /// Very light cyan for subtle accents
  static const Color paleCyan = Color(0xFFE0F4FF);

  // Legacy aliases for compatibility
  static const Color primaryGold = primaryCyan;
  static const Color darkGold = darkCyan;
  static const Color lightGold = lightCyan;
  static const Color paleGold = paleCyan;

  // ===========================================================================
  // SECONDARY COLORS - METALLIC SILVER PALETTE
  // ===========================================================================
  // Silver represents elegance and sophistication

  /// Primary silver color - metallic finish
  static const Color primarySilver = Color(0xFFC8D0D8);

  /// Darker silver for depth
  static const Color darkSilver = Color(0xFF9CA8B0);

  /// Light silver for subtle elements
  static const Color lightSilver = Color(0xFFE8ECF0);

  // ===========================================================================
  // BACKGROUND COLORS - NAVY DARK THEME
  // ===========================================================================

  /// Main scaffold background - deep navy
  static const Color scaffoldBackground = Color(0xFF0A1628);

  /// Card background - slightly lighter navy
  static const Color cardBackground = Color(0xFF1A2A3A);

  /// Surface color for elevated elements
  static const Color surfaceColor = Color(0xFF243444);

  /// Slightly elevated surface
  static const Color elevatedSurface = Color(0xFF2E3E4E);

  /// Dialog/modal background
  static const Color dialogBackground = Color(0xFF1E2E3E);

  // ===========================================================================
  // GLASSMORPHISM COLORS
  // ===========================================================================
  // Semi-transparent colors for glass effect

  /// Glass background with low opacity
  static Color glassBackground = Colors.white.withOpacity(0.05);

  /// Glass border color
  static Color glassBorder = Colors.white.withOpacity(0.1);

  /// Glass shadow
  static Color glassShadow = Colors.black.withOpacity(0.3);

  /// Dark glass for overlays
  static Color darkGlass = const Color(0xFF1A2A3A).withOpacity(0.7);

  // ===========================================================================
  // LIGHT THEME COLORS
  // ===========================================================================
  static const Color scaffoldBackgroundLight =
      Color(0xFFF8FAFC); // Light gray-blue
  static const Color cardBackgroundLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0A1628); // Navy
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Light slate
  static const Color textHintLight = Color(0xFFCBD5E1);
  static const Color iconPrimaryLight = Color(0xFF1E293B);
  static const Color iconSecondaryLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color inputBorderLight = Color(0xFFCBD5E1);

  // ===========================================================================
  // TEXT COLORS
  // ===========================================================================

  /// Primary text - white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - light gray
  static const Color textSecondary = Color(0xFFB0B8C0);

  /// Tertiary text - darker gray
  static const Color textTertiary = Color(0xFF707880);

  /// Disabled text
  static const Color textDisabled = Color(0xFF505860);

  /// Hint text color
  static const Color textHint = Color(0xFF606870);

  // ===========================================================================
  // STATUS COLORS
  // ===========================================================================

  /// Success color - muted green
  static const Color success = Color(0xFF4CAF50);

  /// Error color - muted red
  static const Color error = Color(0xFFE57373);

  /// Warning color - amber
  static const Color warning = Color(0xFFFFB74D);

  /// Info color - cyan (matches theme)
  static const Color info = primaryCyan;

  // ===========================================================================
  // GRADIENT DEFINITIONS
  // ===========================================================================

  /// Premium cyan gradient for buttons and highlights (shiny metallic effect)
  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightCyan, primaryCyan, darkCyan],
  );

  /// Metallic silver gradient (shiny chrome effect)
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightSilver, primarySilver, darkSilver],
  );

  /// Legacy alias
  static const LinearGradient goldGradient = cyanGradient;

  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A2A3A), Color(0xFF0A1628)],
  );

  /// Card gradient for glass effect
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
  );

  /// Shimmer gradient for loading states
  static LinearGradient shimmerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, surfaceColor, cardBackground],
  );

  // ===========================================================================
  // BORDER COLORS
  // ===========================================================================

  /// Subtle border for cards
  static Color cardBorder = Colors.white.withOpacity(0.08);

  /// Input field border
  static const Color inputBorder = Color(0xFF3A4A5A);

  /// Focused input border
  static const Color inputFocusedBorder = primaryCyan;

  /// Divider color
  static const Color divider = Color(0xFF2A3A4A);

  // ===========================================================================
  // ICON COLORS
  // ===========================================================================

  /// Primary icon color
  static const Color iconPrimary = Color(0xFFE0E4E8);

  /// Secondary icon color
  static const Color iconSecondary = Color(0xFF808890);

  /// Accent icon color (cyan)
  static const Color iconAccent = primaryCyan;

  // ===========================================================================
  // RATING COLORS
  // ===========================================================================

  /// Star rating color (cyan)
  static const Color ratingColor = primaryCyan;

  /// Empty star color
  static const Color ratingEmpty = Color(0xFF404850);

  // ===========================================================================
  // MATERIAL COLOR SWATCH
  // ===========================================================================

  /// Primary swatch for Material widgets
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF00A3FF, <int, Color>{
    50: Color(0xFFE0F4FF),
    100: Color(0xFFB3E3FF),
    200: Color(0xFF80D0FF),
    300: Color(0xFF4DBDFF),
    400: Color(0xFF26AEFF),
    500: Color(0xFF00A3FF),
    600: Color(0xFF0095E6),
    700: Color(0xFF0088DD),
    800: Color(0xFF007ACC),
    900: Color(0xFF0066B3),
  });
}
