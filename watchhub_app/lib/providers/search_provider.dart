import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  List<String> _recentSearches = [];
  bool _isSearchExpanded = false;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  bool get isSearchExpanded => _isSearchExpanded;

  SearchProvider() {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      _recentSearches = history;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _recentSearches.remove(query);

    // Add to beginning
    _recentSearches.insert(0, query);

    // Keep only max items
    if (_recentSearches.length > _maxHistoryItems) {
      _recentSearches = _recentSearches.sublist(0, _maxHistoryItems);
    }

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _recentSearches);

    notifyListeners();
  }

  Future<void> removeSearch(String query) async {
    _recentSearches.remove(query);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _recentSearches);

    notifyListeners();
  }

  Future<void> clearHistory() async {
    _recentSearches.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);

    notifyListeners();
  }

  void toggleSearchExpanded() {
    _isSearchExpanded = !_isSearchExpanded;
    notifyListeners();
  }

  void setSearchExpanded(bool value) {
    _isSearchExpanded = value;
    notifyListeners();
  }
}
