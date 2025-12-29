// =============================================================================
// FILE: category_provider.dart
// PURPOSE: Category state management for WatchHub
// DESCRIPTION: Fetches and manages product categories from Firestore.
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/firestore_crud_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryProvider();

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _categories = await _firestoreService.getCategories();

      debugPrint('CategoryProvider: Loaded ${_categories.length} categories');
    } catch (e, stack) {
      debugPrint('CategoryProvider: CRITICAL Error loading categories - $e');
      debugPrint(stack.toString());
      _errorMessage = 'Failed to load categories';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}
