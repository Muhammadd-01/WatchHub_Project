// =============================================================================
// FILE: cart_model.dart
// PURPOSE: Cart and CartItem data models for WatchHub
// DESCRIPTION: Represents a user's shopping cart and individual cart items.
//              Cart is stored at carts/{uid}/items/{productId}
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

/// Represents a single item in the user's cart
///
/// Stored in Firestore at: carts/{uid}/items/{productId}
///
/// The cart is linked to the user via their Firebase Auth UID.
class CartItemModel {
  /// Product ID (same as document ID)
  final String productId;

  /// Quantity of this product in cart
  final int quantity;

  /// When the item was added to cart
  final DateTime addedAt;

  /// Optional: Product details (populated when fetching cart)
  /// This is not stored in Firestore, but joined when reading
  final ProductModel? product;

  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.addedAt,
    this.product,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  /// Creates a CartItemModel from a Firestore document snapshot
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CartItemModel(
      productId: doc.id,
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a CartItemModel from a Map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 1,
      addedAt: map['addedAt'] is Timestamp
          ? (map['addedAt'] as Timestamp).toDate()
          : (map['addedAt'] as DateTime?) ?? DateTime.now(),
      product: map['product'] != null
          ? ProductModel.fromMap(map['product'])
          : null,
    );
  }

  /// Converts to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Converts to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'addedAt': addedAt,
      'product': product?.toMap(),
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  CartItemModel copyWith({
    String? productId,
    int? quantity,
    DateTime? addedAt,
    ProductModel? product,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Subtotal for this item (price × quantity)
  double get subtotal {
    if (product == null) return 0;
    return product!.price * quantity;
  }

  /// Whether the product is available
  bool get isAvailable {
    if (product == null) return false;
    return product!.stock >= quantity;
  }

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return 'CartItemModel(productId: $productId, quantity: $quantity)';
  }
}

/// Represents the entire cart for a user
///
/// This is a convenience class that aggregates cart items
/// and provides cart-level calculations.
class CartModel {
  /// User's Firebase Auth UID
  final String userId;

  /// All items in the cart
  final List<CartItemModel> items;

  CartModel({required this.userId, required this.items});

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Total number of items in cart (sum of quantities)
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Number of unique products in cart
  int get uniqueItems => items.length;

  /// Total cart value
  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Whether the cart is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Check if a product is in the cart
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get the quantity of a product in cart
  int getQuantity(String productId) {
    final item = items.firstWhere(
      (item) => item.productId == productId,
      orElse: () =>
          CartItemModel(productId: '', quantity: 0, addedAt: DateTime.now()),
    );
    return item.quantity;
  }

  /// Check if all items are available
  bool get allItemsAvailable {
    return items.every((item) => item.isAvailable);
  }

  /// Get unavailable items
  List<CartItemModel> get unavailableItems {
    return items.where((item) => !item.isAvailable).toList();
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  CartModel copyWith({String? userId, List<CartItemModel>? items}) {
    return CartModel(userId: userId ?? this.userId, items: items ?? this.items);
  }

  @override
  String toString() {
    return 'CartModel(userId: $userId, items: ${items.length}, total: $totalPrice)';
  }
}
