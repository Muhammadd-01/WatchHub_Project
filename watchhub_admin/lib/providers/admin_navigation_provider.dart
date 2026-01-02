// =============================================================================
// FILE: admin_navigation_provider.dart
// PURPOSE: Manage Navigation State
// DESCRIPTION: Holds the current index of the main shell.
// =============================================================================

import 'package:flutter/material.dart';

class AdminNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
