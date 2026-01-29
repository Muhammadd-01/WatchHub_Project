// =============================================================================
// FILE: admin_product_provider.dart
// PURPOSE: Manage products in Admin Panel
// DESCRIPTION: Handles CRUD operations for products in Firestore.
//              Uses Supabase for Image Storage.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/notification_service.dart';

class AdminProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Collection reference
  CollectionReference get _productCollection =>
      _firestore.collection('products');

  // Fetch products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot =
          await _productCollection.orderBy('createdAt', descending: true).get();
      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Product
  Future<bool> addProduct({
    required String name,
    required String brand,
    required double price,
    required String description,
    required String category,
    required List<XFile> images,
    required Map<String, dynamic> specs,
    required int stock,
    bool isExclusive = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload images to Supabase
      final List<String> imageUrls = await _uploadImages(images);

      // 2. Add to Firestore
      final data = {
        'name': name,
        'brand': brand,
        'price': price,
        'description': description,
        'category': category,
        'images': imageUrls,
        'specs': specs,
        'stock': stock,
        'rating': 0.0,
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isFeatured': false,
        'isNewArrival': true,
        'isExclusive': isExclusive,
      };

      final docRef = await _productCollection.add(data);

      // 3. Send push notification to all users
      await NotificationService.notifyNewProduct(
        productName: name,
        productBrand: brand,
        productId: docRef.id,
      );

      // Refresh list
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Product
  Future<bool> updateProduct({
    required String id,
    Map<String, dynamic>? data,
    List<XFile>? newImages,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> updates = data ?? {};

      if (newImages != null && newImages.isNotEmpty) {
        final List<String> imageUrls = await _uploadImages(newImages);
        final existingImages =
            (updates['images'] as List<dynamic>?)?.cast<String>() ?? [];
        updates['images'] = [...existingImages, ...imageUrls];
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      if (updates.containsKey('stock')) {
        final newStock = updates['stock'] as int?;
        if (newStock != null && newStock <= 0) {
          // 1. Trigger admin restock alert
          _triggerRestockAlert(id, updates['name'] as String?);

          // 2. Find all users who have this product in their cart/wishlist (non-blocking)
          String productName = updates['name'] as String? ?? 'Product';
          if (!updates.containsKey('name')) {
            try {
              final doc = await _productCollection.doc(id).get();
              final docData = doc.data() as Map<String, dynamic>?;
              productName = docData?['name'] ?? 'Product';
            } catch (_) {}
          }
          _cleanupUserCollections(id, productName);
        }
      }

      await _productCollection.doc(id).update(updates);

      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Find users with this product in cart/wishlist and cleanup
  Future<void> _cleanupUserCollections(
      String productId, String productName) async {
    try {
      // Query all 'items' subcollections (this handles both carts and wishlists as they share the subcollection name)
      final items = await _firestore
          .collectionGroup('items')
          .where('productId', isEqualTo: productId)
          .get();

      for (final doc in items.docs) {
        try {
          // Path: carts/{userId}/items/{productId} OR wishlists/{userId}/items/{productId}
          final pathParts = doc.reference.path.split('/');
          if (pathParts.length < 2) continue;

          final collectionType = pathParts[0]; // 'carts' or 'wishlists'
          final userId = pathParts[1];

          if (collectionType == 'carts') {
            // Create notification for user at users/{userId}/notifications
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .add({
              'title': 'Item Unavailable',
              'message':
                  'A product ($productName) in your cart is no longer available and has been removed.',
              'read': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
            debugPrint('Removed $productName from cart for user $userId');
          } else if (collectionType == 'wishlists') {
            debugPrint('Removed $productName from wishlist for user $userId');
          }

          // Remove the item regardless of collection type
          await doc.reference.delete();
        } catch (e) {
          debugPrint('Error processing item for cleanup: $e');
        }
      }
    } catch (e) {
      debugPrint('Error performing collection cleanup: $e');
    }
  }

  // Delete Product
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get product data to find images
      final productDoc = await _productCollection.doc(id).get();
      List<dynamic>? imagesToDelete;

      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>?;
        imagesToDelete = data?['images'] as List<dynamic>?;
      }

      // 2. Delete from Firestore first (fast operation)
      final productName = _products.firstWhere(
        (p) => p['id'] == id,
        orElse: () => {'name': 'Product'},
      )['name'];

      await _productCollection.doc(id).delete();
      _products.removeWhere((p) => p['id'] == id);

      // 3. Cleanup user carts and wishlists (non-blocking)
      _cleanupUserCollections(id, productName);

      // 4. Delete images from Supabase in background (non-blocking)
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        _deleteImagesInBackground(imagesToDelete);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes images from Supabase storage in the background
  void _deleteImagesInBackground(List<dynamic> images) {
    Future.microtask(() async {
      for (final imageUrl in images) {
        try {
          final uri = Uri.parse(imageUrl as String);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('product-images');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('product-images').remove([filePath]);
            debugPrint('Deleted image: $filePath');
          }
        } catch (e) {
          debugPrint('Failed to delete image from Supabase: $e');
        }
      }
    });
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> urls = [];
    try {
      for (var image in images) {
        final fileName =
            'products/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final bytes = await image.readAsBytes();

        await _supabase.storage.from('product-images').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: image.mimeType),
            );

        final url =
            _supabase.storage.from('product-images').getPublicUrl(fileName);
        urls.add(url);
      }
      return urls;
    } on StorageException catch (e) {
      String message = 'Supabase Storage error: ${e.message}';
      if (e.statusCode == '404') {
        message =
            'Bucket "product-images" not found. Please create it in Supabase.';
      } else if (e.statusCode == '403') {
        message = 'Access denied to bucket. Check RLS policies.';
      }
      debugPrint('AdminProductProvider: $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('AdminProductProvider: Unexpected error during upload - $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Trigger a restock alert in admin_notifications
  Future<void> _triggerRestockAlert(
      String productId, String? productName) async {
    try {
      String name = productName ?? 'A product';
      if (productName == null) {
        final doc = await _productCollection.doc(productId).get();
        name = (doc.data() as Map<String, dynamic>?)?['name'] ?? 'A product';
      }

      await _firestore.collection('admin_notifications').add({
        'type': 'restock_alert',
        'title': 'Out of Stock Alert',
        'message': '$name is currently out of stock. Please restock it soon.',
        'productId': productId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Restock alert triggered for $name');
    } catch (e) {
      debugPrint('Error triggering restock alert: $e');
    }
  }

  // Fetch Reviews
  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    try {
      final snapshot = await _productCollection
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Ensure createdAt is a DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }
}
