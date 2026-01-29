// =============================================================================
// FILE: brand_model.dart
// PURPOSE: Data model for watch brands in WatchHub
// DESCRIPTION: Represents a brand with a logo and name.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Watch brand model
class BrandModel {
  final String id;
  final String name;
  final String? logoUrl;

  BrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  /// Creates a BrandModel from Firestore document
  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
    );
  }

  /// Converts BrandModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
    };
  }
}
