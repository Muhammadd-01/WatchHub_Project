// =============================================================================
// FILE: wishlist_model.dart
// PURPOSE: Wishlist data model for WatchHub
// DESCRIPTION: Represents a user's wishlist of products they want to save.
//              Wishlist is stored at wishlists/{uid}/items/{productId}
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

/// Represents a single item in the user's wishlist
///
/// Stored in Firestore at: wishlists/{uid}/items/{productId}
///
/// The wishlist is linked to the user via their Firebase Auth UID.
class WishlistItemModel {
  /// Product ID (same as document ID)
  final String productId;

  /// When the item was added to wishlist
  final DateTime addedAt;

  /// Optional: Product details (populated when fetching wishlist)
  final ProductModel? product;

  WishlistItemModel({
    required this.productId,
    required this.addedAt,
    this.product,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  factory WishlistItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WishlistItemModel(
      productId: doc.id,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      productId: map['productId'] ?? '',
      addedAt: map['addedAt'] is Timestamp
          ? (map['addedAt'] as Timestamp).toDate()
          : (map['addedAt'] as DateTime?) ?? DateTime.now(),
      product: map['product'] != null
          ? ProductModel.fromMap(map['product'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'productId': productId, 'addedAt': Timestamp.fromDate(addedAt)};
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'addedAt': addedAt,
      'product': product?.toMap(),
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  WishlistItemModel copyWith({
    String? productId,
    DateTime? addedAt,
    ProductModel? product,
  }) {
    return WishlistItemModel(
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
    );
  }

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItemModel && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return 'WishlistItemModel(productId: $productId, addedAt: $addedAt)';
  }
}

/// Represents the entire wishlist for a user
class WishlistModel {
  /// User's Firebase Auth UID
  final String userId;

  /// All items in the wishlist
  final List<WishlistItemModel> items;

  WishlistModel({required this.userId, required this.items});

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Number of items in wishlist
  int get count => items.length;

  /// Whether the wishlist is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the wishlist is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Check if a product is in the wishlist
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Total value of wishlist items
  double get totalValue {
    return items.fold(0.0, (sum, item) => sum + (item.product?.price ?? 0));
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  WishlistModel copyWith({String? userId, List<WishlistItemModel>? items}) {
    return WishlistModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'WishlistModel(userId: $userId, items: ${items.length})';
  }
}
