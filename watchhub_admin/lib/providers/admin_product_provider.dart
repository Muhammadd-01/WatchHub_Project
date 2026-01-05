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
      };

      await _productCollection.add(data);

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

  // Delete Product
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productCollection.doc(id).delete();
      _products.removeWhere((p) => p['id'] == id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
