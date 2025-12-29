// =============================================================================
// FILE: admin_category_provider.dart
// PURPOSE: Manage Categories
// DESCRIPTION: CRUD for categories.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot =
          await _firestore.collection('categories').orderBy('name').get();
      _categories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}
