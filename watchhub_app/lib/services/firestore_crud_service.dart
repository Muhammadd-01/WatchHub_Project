// =============================================================================
// FILE: firestore_crud_service.dart
// PURPOSE: Centralized Firestore CRUD operations for WatchHub
// DESCRIPTION: This is the SINGLE FILE that handles ALL Firestore operations.
//              Collections are auto-created when first accessed.
//              NO Firestore logic should exist in UI files.
// =============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/feedback_model.dart';

/// Centralized Firestore CRUD Service
///
/// IMPORTANT RULES:
/// 1. ALL Firestore operations go through this service
/// 2. NO Firestore code in UI/screen files
/// 3. Collections are auto-created on first document write
/// 4. User-specific collections use Firebase Auth UID as document ID
///
/// Collection Structure:
/// - users/{uid}                           → User profiles
/// - products/{productId}                  → Watch products
/// - carts/{uid}/items/{productId}         → User carts
/// - wishlists/{uid}/items/{productId}     → User wishlists
/// - orders/{orderId}                      → Orders
/// - products/{productId}/reviews/{reviewId} → Product reviews
/// - feedbacks/{feedbackId}                → User feedback
class FirestoreCrudService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // COLLECTION REFERENCES
  // ===========================================================================

  /// Users collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection);

  /// Products collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection(AppConstants.productsCollection);

  /// Carts collection reference
  CollectionReference<Map<String, dynamic>> get _cartsCollection =>
      _firestore.collection(AppConstants.cartsCollection);

  /// Wishlists collection reference
  CollectionReference<Map<String, dynamic>> get _wishlistsCollection =>
      _firestore.collection(AppConstants.wishlistsCollection);

  /// Orders collection reference
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(AppConstants.ordersCollection);

  /// Feedbacks collection reference
  CollectionReference<Map<String, dynamic>> get _feedbacksCollection =>
      _firestore.collection(AppConstants.feedbacksCollection);

  // ===========================================================================
  // USER CRUD OPERATIONS
  // ===========================================================================

  /// Creates a new user document in Firestore
  ///
  /// CRITICAL: The document ID is the Firebase Auth UID
  /// This ensures consistent user identification across all services.
  ///
  /// The collection is auto-created if it doesn't exist.
  Future<void> createUser(UserModel user) async {
    try {
      debugPrint(
        'FirestoreCrudService: Creating user document for UID: ${user.uid}',
      );

      // Use the UID as the document ID
      await _usersCollection.doc(user.uid).set(user.toFirestore());

      debugPrint('FirestoreCrudService: User document created successfully');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error creating user - $e');
      rethrow;
    }
  }

  /// Gets a user document by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();

      if (!doc.exists) {
        debugPrint('FirestoreCrudService: User not found for UID: $uid');
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting user - $e');
      rethrow;
    }
  }

  /// Updates a user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      // Add updated timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(uid).update(data);
      debugPrint('FirestoreCrudService: User updated successfully');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating user - $e');
      rethrow;
    }
  }

  /// Deletes a user document
  Future<void> deleteUser(String uid) async {
    try {
      // Delete user's cart
      await _deleteSubcollection(
        _cartsCollection
            .doc(uid)
            .collection(AppConstants.cartItemsSubcollection),
      );

      // Delete user's wishlist
      await _deleteSubcollection(
        _wishlistsCollection
            .doc(uid)
            .collection(AppConstants.wishlistItemsSubcollection),
      );

      // Delete user document
      await _usersCollection.doc(uid).delete();

      debugPrint('FirestoreCrudService: User and related data deleted');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error deleting user - $e');
      rethrow;
    }
  }

  /// Stream of user document changes
  Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ===========================================================================
  // PRODUCT CRUD OPERATIONS
  // ===========================================================================

  /// Gets all products
  Future<List<ProductModel>> getProducts({
    String? brand,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    bool? isNewArrival,
    String? sortBy,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsCollection;

      // Apply filters
      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      if (isNewArrival != null) {
        query = query.where('isNewArrival', isEqualTo: isNewArrival);
      }

      // Apply sorting
      switch (sortBy) {
        case 'price_asc':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_desc':
          query = query.orderBy('price', descending: true);
          break;
        case 'rating':
          query = query.orderBy('rating', descending: true);
          break;
        case 'newest':
          query = query.orderBy('createdAt', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      List<ProductModel> products =
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

      // Apply price filter in memory (Firestore doesn't support range on multiple fields)
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null && maxPrice != double.infinity) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }

      return products;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting products - $e');
      rethrow;
    }
  }

  /// Gets a single product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      return ProductModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting product - $e');
      rethrow;
    }
  }

  /// Adds a new product (for admin use)
  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toFirestore());
      debugPrint('FirestoreCrudService: Product added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error adding product - $e');
      rethrow;
    }
  }

  /// Updates a product
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _productsCollection.doc(productId).update(data);
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating product - $e');
      rethrow;
    }
  }

  /// Deletes a product
  Future<void> deleteProduct(String productId) async {
    try {
      // Delete product reviews subcollection
      await _deleteSubcollection(
        _productsCollection
            .doc(productId)
            .collection(AppConstants.reviewsSubcollection),
      );

      // Delete product document
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error deleting product - $e');
      rethrow;
    }
  }

  /// Searches products by name or brand
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Firestore doesn't support full-text search natively
      // We'll fetch all products and filter in memory
      // For production, consider using Algolia or similar
      final snapshot = await _productsCollection.get();

      final queryLower = query.toLowerCase();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where(
            (product) =>
                product.name.toLowerCase().contains(queryLower) ||
                product.brand.toLowerCase().contains(queryLower) ||
                product.description.toLowerCase().contains(queryLower),
          )
          .toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error searching products - $e');
      rethrow;
    }
  }

  /// Stream of products
  Stream<List<ProductModel>> productsStream({String? brand, String? category}) {
    Query<Map<String, dynamic>> query = _productsCollection;

    if (brand != null) {
      query = query.where('brand', isEqualTo: brand);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ===========================================================================
  // CART CRUD OPERATIONS
  // ===========================================================================

  /// Gets the cart items for a user
  ///
  /// Cart is stored at: carts/{uid}/items/{productId}
  Future<List<CartItemModel>> getCartItems(String uid) async {
    try {
      final snapshot = await _cartsCollection
          .doc(uid)
          .collection(AppConstants.cartItemsSubcollection)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting cart - $e');
      rethrow;
    }
  }

  /// Gets cart items with product details populated
  Future<List<CartItemModel>> getCartWithProducts(String uid) async {
    try {
      final cartItems = await getCartItems(uid);

      // Populate product details
      final populatedItems = <CartItemModel>[];

      for (final item in cartItems) {
        final product = await getProduct(item.productId);
        populatedItems.add(item.copyWith(product: product));
      }

      return populatedItems;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting cart with products - $e');
      rethrow;
    }
  }

  /// Adds a product to the user's cart
  Future<void> addToCart(
    String uid,
    String productId, {
    int quantity = 1,
  }) async {
    try {
      final cartItemRef = _cartsCollection
          .doc(uid)
          .collection(AppConstants.cartItemsSubcollection)
          .doc(productId);

      final existingItem = await cartItemRef.get();

      if (existingItem.exists) {
        // Update quantity if already in cart
        await cartItemRef.update({'quantity': FieldValue.increment(quantity)});
      } else {
        // Add new item
        await cartItemRef.set({
          'productId': productId,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('FirestoreCrudService: Added to cart - $productId');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error adding to cart - $e');
      rethrow;
    }
  }

  /// Removes a product from the user's cart
  Future<void> removeFromCart(String uid, String productId) async {
    try {
      await _cartsCollection
          .doc(uid)
          .collection(AppConstants.cartItemsSubcollection)
          .doc(productId)
          .delete();

      debugPrint('FirestoreCrudService: Removed from cart - $productId');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error removing from cart - $e');
      rethrow;
    }
  }

  /// Updates the quantity of a cart item
  Future<void> updateCartQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(uid, productId);
        return;
      }

      await _cartsCollection
          .doc(uid)
          .collection(AppConstants.cartItemsSubcollection)
          .doc(productId)
          .update({'quantity': quantity});

      debugPrint(
        'FirestoreCrudService: Updated cart quantity - $productId: $quantity',
      );
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating cart quantity - $e');
      rethrow;
    }
  }

  /// Clears all items from the user's cart
  Future<void> clearCart(String uid) async {
    try {
      await _deleteSubcollection(
        _cartsCollection
            .doc(uid)
            .collection(AppConstants.cartItemsSubcollection),
      );
      debugPrint('FirestoreCrudService: Cart cleared');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error clearing cart - $e');
      rethrow;
    }
  }

  /// Stream of cart items
  Stream<List<CartItemModel>> cartStream(String uid) {
    return _cartsCollection
        .doc(uid)
        .collection(AppConstants.cartItemsSubcollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Gets cart item count
  Future<int> getCartCount(String uid) async {
    try {
      final snapshot = await _cartsCollection
          .doc(uid)
          .collection(AppConstants.cartItemsSubcollection)
          .get();

      return snapshot.docs.fold(0, (sum, doc) {
        final data = doc.data();
        return sum + (data['quantity'] as int? ?? 1);
      });
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting cart count - $e');
      return 0;
    }
  }

  // ===========================================================================
  // WISHLIST CRUD OPERATIONS
  // ===========================================================================

  /// Gets the wishlist items for a user
  Future<List<WishlistItemModel>> getWishlistItems(String uid) async {
    try {
      final snapshot = await _wishlistsCollection
          .doc(uid)
          .collection(AppConstants.wishlistItemsSubcollection)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WishlistItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting wishlist - $e');
      rethrow;
    }
  }

  /// Gets wishlist items with product details
  Future<List<WishlistItemModel>> getWishlistWithProducts(String uid) async {
    try {
      final wishlistItems = await getWishlistItems(uid);

      final populatedItems = <WishlistItemModel>[];

      for (final item in wishlistItems) {
        final product = await getProduct(item.productId);
        populatedItems.add(item.copyWith(product: product));
      }

      return populatedItems;
    } catch (e) {
      debugPrint(
        'FirestoreCrudService: Error getting wishlist with products - $e',
      );
      rethrow;
    }
  }

  /// Adds a product to the user's wishlist
  Future<void> addToWishlist(String uid, String productId) async {
    try {
      await _wishlistsCollection
          .doc(uid)
          .collection(AppConstants.wishlistItemsSubcollection)
          .doc(productId)
          .set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FirestoreCrudService: Added to wishlist - $productId');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error adding to wishlist - $e');
      rethrow;
    }
  }

  /// Removes a product from the user's wishlist
  Future<void> removeFromWishlist(String uid, String productId) async {
    try {
      await _wishlistsCollection
          .doc(uid)
          .collection(AppConstants.wishlistItemsSubcollection)
          .doc(productId)
          .delete();

      debugPrint('FirestoreCrudService: Removed from wishlist - $productId');
    } catch (e) {
      debugPrint('FirestoreCrudService: Error removing from wishlist - $e');
      rethrow;
    }
  }

  /// Checks if a product is in the wishlist
  Future<bool> isInWishlist(String uid, String productId) async {
    try {
      final doc = await _wishlistsCollection
          .doc(uid)
          .collection(AppConstants.wishlistItemsSubcollection)
          .doc(productId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error checking wishlist - $e');
      return false;
    }
  }

  /// Moves a wishlist item to cart
  Future<void> moveWishlistToCart(String uid, String productId) async {
    try {
      await addToCart(uid, productId);
      await removeFromWishlist(uid, productId);
      debugPrint(
        'FirestoreCrudService: Moved from wishlist to cart - $productId',
      );
    } catch (e) {
      debugPrint('FirestoreCrudService: Error moving to cart - $e');
      rethrow;
    }
  }

  /// Stream of wishlist items
  Stream<List<WishlistItemModel>> wishlistStream(String uid) {
    return _wishlistsCollection
        .doc(uid)
        .collection(AppConstants.wishlistItemsSubcollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WishlistItemModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ===========================================================================
  // ORDER CRUD OPERATIONS
  // ===========================================================================

  /// Creates a new order
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add(order.toFirestore());
      debugPrint('FirestoreCrudService: Order created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error creating order - $e');
      rethrow;
    }
  }

  /// Gets orders for a user
  Future<List<OrderModel>> getOrders(String uid) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting orders - $e');
      rethrow;
    }
  }

  /// Gets a single order
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting order - $e');
      rethrow;
    }
  }

  /// Updates order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
        'FirestoreCrudService: Order status updated - $orderId: $status',
      );
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating order status - $e');
      rethrow;
    }
  }

  /// Stream of user's orders
  Stream<List<OrderModel>> ordersStream(String uid) {
    return _ordersCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Generates a unique order number
  Future<String> generateOrderNumber() async {
    final year = DateTime.now().year;

    // Get count of orders this year
    final snapshot = await _ordersCollection
        .where('createdAt', isGreaterThanOrEqualTo: DateTime(year))
        .get();

    final orderCount = snapshot.docs.length + 1;

    return 'WH-$year-${orderCount.toString().padLeft(6, '0')}';
  }

  // ===========================================================================
  // REVIEW CRUD OPERATIONS
  // ===========================================================================

  /// Gets reviews for a product
  Future<List<ReviewModel>> getReviews(
    String productId, {
    String? sortBy,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsCollection
          .doc(productId)
          .collection(AppConstants.reviewsSubcollection);

      switch (sortBy) {
        case 'rating_high':
          query = query.orderBy('rating', descending: true);
          break;
        case 'rating_low':
          query = query.orderBy('rating', descending: false);
          break;
        case 'helpful':
          query = query.orderBy('helpfulCount', descending: true);
          break;
        case 'newest':
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc, productId))
          .toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting reviews - $e');
      rethrow;
    }
  }

  /// Adds a review for a product
  Future<void> addReview(ReviewModel review) async {
    try {
      // Add the review
      await _productsCollection
          .doc(review.productId)
          .collection(AppConstants.reviewsSubcollection)
          .add(review.toFirestore());

      // Update product rating
      await _updateProductRating(review.productId);

      debugPrint(
        'FirestoreCrudService: Review added for product ${review.productId}',
      );
    } catch (e) {
      debugPrint('FirestoreCrudService: Error adding review - $e');
      rethrow;
    }
  }

  /// Updates a review
  Future<void> updateReview(
    String productId,
    String reviewId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['isEdited'] = true;
      data['editedAt'] = FieldValue.serverTimestamp();

      await _productsCollection
          .doc(productId)
          .collection(AppConstants.reviewsSubcollection)
          .doc(reviewId)
          .update(data);

      // Update product rating if rating changed
      if (data.containsKey('rating')) {
        await _updateProductRating(productId);
      }
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating review - $e');
      rethrow;
    }
  }

  /// Deletes a review
  Future<void> deleteReview(String productId, String reviewId) async {
    try {
      await _productsCollection
          .doc(productId)
          .collection(AppConstants.reviewsSubcollection)
          .doc(reviewId)
          .delete();

      await _updateProductRating(productId);
    } catch (e) {
      debugPrint('FirestoreCrudService: Error deleting review - $e');
      rethrow;
    }
  }

  /// Checks if user has reviewed a product
  Future<bool> hasUserReviewed(String productId, String uid) async {
    try {
      final snapshot = await _productsCollection
          .doc(productId)
          .collection(AppConstants.reviewsSubcollection)
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error checking review status - $e');
      return false;
    }
  }

  /// Updates product rating based on reviews
  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = await getReviews(productId);

      if (reviews.isEmpty) {
        await updateProduct(productId, {'rating': 0, 'reviewCount': 0});
        return;
      }

      final avgRating =
          reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

      await updateProduct(productId, {
        'rating': double.parse(avgRating.toStringAsFixed(1)),
        'reviewCount': reviews.length,
      });
    } catch (e) {
      debugPrint('FirestoreCrudService: Error updating product rating - $e');
    }
  }

  /// Stream of reviews for a product
  Stream<List<ReviewModel>> reviewsStream(String productId) {
    return _productsCollection
        .doc(productId)
        .collection(AppConstants.reviewsSubcollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc, productId))
              .toList(),
        );
  }

  // ===========================================================================
  // FEEDBACK CRUD OPERATIONS
  // ===========================================================================

  /// Submits user feedback
  Future<String> submitFeedback(FeedbackModel feedback) async {
    try {
      final docRef = await _feedbacksCollection.add(feedback.toFirestore());
      debugPrint(
        'FirestoreCrudService: Feedback submitted with ID: ${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreCrudService: Error submitting feedback - $e');
      rethrow;
    }
  }

  /// Gets feedback submitted by a user
  Future<List<FeedbackModel>> getUserFeedback(String uid) async {
    try {
      final snapshot = await _feedbacksCollection
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('FirestoreCrudService: Error getting user feedback - $e');
      rethrow;
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Deletes all documents in a subcollection
  Future<void> _deleteSubcollection(CollectionReference collection) async {
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Batch write for efficiency
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _firestore.batch();

    for (final op in operations) {
      final type = op['type'] as String;
      final ref = op['ref'] as DocumentReference;
      final data = op['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'set':
          batch.set(ref, data!);
          break;
        case 'update':
          batch.update(ref, data!);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    }

    await batch.commit();
  }
}

extension on FutureOr<int> {
  FutureOr<int> operator +(int other) {
    final val = this;
    if (val is int) {
      return val + other;
    } else {
      return val.then((v) => v + other);
    }
  }
}
