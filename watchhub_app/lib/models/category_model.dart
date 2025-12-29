// =============================================================================
// FILE: category_model.dart
// PURPOSE: Data model for product categories in WatchHub
// DESCRIPTION: Represents a category with an icon, image, and name.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Product category model
class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? icon;
  final int? order;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.icon,
    this.order,
  });

  /// Creates a CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      icon: data['icon'],
      order: data['order'],
    );
  }

  /// Converts CategoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'icon': icon,
      'order': order,
    };
  }
}
