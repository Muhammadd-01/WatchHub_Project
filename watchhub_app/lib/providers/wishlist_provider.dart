// =============================================================================
// FILE: wishlist_provider.dart
// PURPOSE: Wishlist state management for WatchHub
// DESCRIPTION: Manages the user's wishlist. Wishlist is stored in Firestore
//              at wishlists/{uid}/items/{productId} using the Firebase Auth UID.
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/wishlist_model.dart';
import '../models/product_model.dart';
import '../services/firestore_crud_service.dart';

/// Wishlist state provider
///
/// This provider:
/// - Manages wishlist items (add, remove)
/// - Provides move to cart functionality
/// - Syncs with Firestore using UID
class WishlistProvider extends ChangeNotifier {
  // Service
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  // State
  List<WishlistItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUid;

  // Stream subscription
  StreamSubscription? _wishlistSubscription;

  // Getters
  List<WishlistItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get count => _items.length;

  /// Total value of wishlist items
  double get totalValue {
    return _items.fold(0.0, (sum, item) => sum + (item.product?.price ?? 0));
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes the wishlist for a user
  void initialize(String uid) {
    if (_currentUid == uid) return;

    _currentUid = uid;
    _startWishlistStream(uid);
  }

  /// Starts listening to wishlist changes
  void _startWishlistStream(String uid) {
    _wishlistSubscription?.cancel();

    _wishlistSubscription = _firestoreService
        .wishlistStream(uid)
        .listen(
          (items) async {
            final populatedItems = <WishlistItemModel>[];

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
            debugPrint('WishlistProvider: Wishlist stream error - $error');
          },
        );
  }

  /// Clears wishlist state (on logout)
  void clear() {
    _wishlistSubscription?.cancel();
    _items = [];
    _currentUid = null;
    notifyListeners();
  }

  // ===========================================================================
  // LOAD WISHLIST
  // ===========================================================================

  /// Loads wishlist items from Firestore
  Future<void> loadWishlist(String uid) async {
    try {
      _setLoading(true);
      _clearError();

      _items = await _firestoreService.getWishlistWithProducts(uid);

      debugPrint('WishlistProvider: Loaded ${_items.length} wishlist items');

      notifyListeners();
    } catch (e) {
      debugPrint('WishlistProvider: Error loading wishlist - $e');
      _setError('Failed to load wishlist');
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // ADD TO WISHLIST
  // ===========================================================================

  /// Adds a product to the wishlist
  Future<bool> addToWishlist(String uid, ProductModel product) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.addToWishlist(uid, product.id);

      // Optimistic update
      if (!isInWishlist(product.id)) {
        _items.add(
          WishlistItemModel(
            productId: product.id,
            addedAt: DateTime.now(),
            product: product,
          ),
        );
      }

      debugPrint('WishlistProvider: Added ${product.name} to wishlist');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WishlistProvider: Error adding to wishlist - $e');
      _setError('Failed to add to wishlist');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // REMOVE FROM WISHLIST
  // ===========================================================================

  /// Removes a product from the wishlist
  Future<bool> removeFromWishlist(String uid, String productId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.removeFromWishlist(uid, productId);

      // Optimistic update
      _items.removeWhere((item) => item.productId == productId);

      debugPrint('WishlistProvider: Removed item from wishlist');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WishlistProvider: Error removing from wishlist - $e');
      _setError('Failed to remove from wishlist');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // TOGGLE WISHLIST
  // ===========================================================================

  /// Toggles a product's presence in the wishlist
  Future<bool> toggleWishlist(String uid, ProductModel product) async {
    if (isInWishlist(product.id)) {
      return removeFromWishlist(uid, product.id);
    } else {
      return addToWishlist(uid, product);
    }
  }

  // ===========================================================================
  // MOVE TO CART
  // ===========================================================================

  /// Moves a wishlist item to the cart
  Future<bool> moveToCart(String uid, String productId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.moveWishlistToCart(uid, productId);

      // Optimistic update
      _items.removeWhere((item) => item.productId == productId);

      debugPrint('WishlistProvider: Moved item to cart');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WishlistProvider: Error moving to cart - $e');
      _setError('Failed to move to cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Checks if a product is in the wishlist
  bool isInWishlist(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Gets a wishlist item by product ID
  WishlistItemModel? getWishlistItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
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
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
