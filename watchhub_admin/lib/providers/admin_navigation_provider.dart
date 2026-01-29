// =============================================================================
// FILE: admin_navigation_provider.dart
// PURPOSE: Manage Navigation State
// DESCRIPTION: Holds the current index of the main shell.
// =============================================================================

import 'package:flutter/material.dart';

class AdminNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isSidebarCollapsed = false;

  int get currentIndex => _currentIndex;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }
}
