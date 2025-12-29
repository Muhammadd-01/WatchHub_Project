// =============================================================================
// FILE: theme_provider.dart
// PURPOSE: Theme state management for WatchHub
// DESCRIPTION: Manages the current theme mode (light/dark/system) and persists
//              preference using shared_preferences (to be added later).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // In a real app with context access, we'd check platform brightness.
      // For now, default system to dark as it's the primary design.
      return true;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _updateSystemOverlay();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateSystemOverlay();
    notifyListeners();
  }

  void _updateSystemOverlay() {
    // We can explicitly set overlay styles if needed,
    // but usually AppTheme properties handle this automatically.
    // This is a hook for future customization.
  }
}
