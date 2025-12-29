// =============================================================================
// FILE: cart_provider.dart
// PURPOSE: Cart state management for WatchHub
// DESCRIPTION: Manages the user's shopping cart. Cart is stored in Firestore
//              at carts/{uid}/items/{productId} using the Firebase Auth UID.
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/firestore_crud_service.dart';

/// Cart state provider
///
/// This provider:
/// - Manages cart items (add, remove, update quantity)
/// - Calculates totals
/// - Syncs with Firestore using UID
/// - Provides real-time updates via streams
class CartProvider extends ChangeNotifier {
  // Service
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  // State
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUid;

  // Stream subscription
  StreamSubscription? _cartSubscription;

  // Getters
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Total number of items (sum of quantities)
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Number of unique products
  int get uniqueItems => _items.length;

  /// Total cart value
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Formatted total
  String get formattedTotal {
    return '\$${totalPrice.toStringAsFixed(2)}';
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes the cart for a user
  void initialize(String uid) {
    if (_currentUid == uid) return; // Already initialized

    _currentUid = uid;
    _startCartStream(uid);
  }

  /// Starts listening to cart changes
  void _startCartStream(String uid) {
    _cartSubscription?.cancel();

    _cartSubscription = _firestoreService
        .cartStream(uid)
        .listen(
          (items) async {
            // Populate product details
            final populatedItems = <CartItemModel>[];

            for (final item in items) {
              final product = await _firestoreService.getProduct(
                item.productId,
              );
              populatedItems.add(item.copyWith(product: product));
            }

            _items = populatedItems;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('CartProvider: Cart stream error - $error');
          },
        );
  }

  /// Clears cart state (on logout)
  void clear() {
    _cartSubscription?.cancel();
    _items = [];
    _currentUid = null;
    notifyListeners();
  }

  // ===========================================================================
  // LOAD CART
  // ===========================================================================

  /// Loads cart items from Firestore
  Future<void> loadCart(String uid) async {
    try {
      _setLoading(true);
      _clearError();

      _items = await _firestoreService.getCartWithProducts(uid);

      debugPrint('CartProvider: Loaded ${_items.length} cart items');

      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error loading cart - $e');
      _setError('Failed to load cart');
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // ADD TO CART
  // ===========================================================================

  /// Adds a product to the cart
  Future<bool> addToCart(
    String uid,
    ProductModel product, {
    int quantity = 1,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.addToCart(uid, product.id, quantity: quantity);

      // Optimistic update
      final existingIndex = _items.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingIndex != -1) {
        // Update quantity
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item
        _items.add(
          CartItemModel(
            productId: product.id,
            quantity: quantity,
            addedAt: DateTime.now(),
            product: product,
          ),
        );
      }

      debugPrint('CartProvider: Added ${product.name} to cart');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CartProvider: Error adding to cart - $e');
      _setError('Failed to add to cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // REMOVE FROM CART
  // ===========================================================================

  /// Removes a product from the cart
  Future<bool> removeFromCart(String uid, String productId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.removeFromCart(uid, productId);

      // Optimistic update
      _items.removeWhere((item) => item.productId == productId);

      debugPrint('CartProvider: Removed item from cart');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CartProvider: Error removing from cart - $e');
      _setError('Failed to remove from cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // UPDATE QUANTITY
  // ===========================================================================

  /// Updates the quantity of a cart item
  Future<bool> updateQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      return removeFromCart(uid, productId);
    }

    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateCartQuantity(uid, productId, quantity);

      // Optimistic update
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }

      debugPrint('CartProvider: Updated quantity to $quantity');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CartProvider: Error updating quantity - $e');
      _setError('Failed to update quantity');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Increments the quantity of a cart item
  Future<bool> incrementQuantity(String uid, String productId) async {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () =>
          CartItemModel(productId: '', quantity: 0, addedAt: DateTime.now()),
    );

    if (item.productId.isEmpty) return false;

    // Check stock
    if (item.product != null && item.quantity >= item.product!.stock) {
      _setError('Maximum available stock reached');
      return false;
    }

    return updateQuantity(uid, productId, item.quantity + 1);
  }

  /// Decrements the quantity of a cart item
  Future<bool> decrementQuantity(String uid, String productId) async {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () =>
          CartItemModel(productId: '', quantity: 0, addedAt: DateTime.now()),
    );

    if (item.productId.isEmpty) return false;

    return updateQuantity(uid, productId, item.quantity - 1);
  }

  // ===========================================================================
  // CLEAR CART
  // ===========================================================================

  /// Clears all items from the cart
  Future<bool> clearCart(String uid) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.clearCart(uid);

      _items = [];

      debugPrint('CartProvider: Cart cleared');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CartProvider: Error clearing cart - $e');
      _setError('Failed to clear cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Checks if a product is in the cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Gets the quantity of a product in the cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () =>
          CartItemModel(productId: '', quantity: 0, addedAt: DateTime.now()),
    );
    return item.quantity;
  }

  /// Gets a cart item by product ID
  CartItemModel? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Checks if all items are available
  bool get allItemsAvailable {
    return _items.every((item) => item.isAvailable);
  }

  /// Gets unavailable items
  List<CartItemModel> get unavailableItems {
    return _items.where((item) => !item.isAvailable).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
