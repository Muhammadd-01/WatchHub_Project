// =============================================================================
// FILE: supabase_service.dart
// PURPOSE: Supabase Storage service for WatchHub
// DESCRIPTION: Handles all image storage operations. ALL images (product images,
//              profile images) are stored in Supabase Storage, NOT Firebase Storage.
// =============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

/// Supabase Storage Service for WatchHub
///
/// IMPORTANT: Firebase Storage is NOT used in this project.
/// All images are stored in Supabase Storage.
///
/// Buckets:
/// - product-images: For all product/watch images
/// - profile-images: For user profile pictures
///
/// Usage:
/// 1. Upload image → Get Supabase URL
/// 2. Store ONLY the URL in Firestore
/// 3. Use the URL to display images with CachedNetworkImage
class SupabaseService {
  // Supabase client instance
  SupabaseClient get _client => Supabase.instance.client;

  // UUID generator for unique file names
  final _uuid = const Uuid();

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes Supabase with the provided credentials
  ///
  /// This should be called in main.dart before runApp()
  ///
  /// Parameters:
  /// - [url]: Your Supabase project URL
  /// - [anonKey]: Your Supabase anonymous key
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    debugPrint('SupabaseService: Initialized successfully');
  }

  // ===========================================================================
  // PRODUCT IMAGES
  // ===========================================================================

  /// Uploads a product image to Supabase Storage
  ///
  /// Parameters:
  /// - [imageFile]: The image file to upload
  /// - [productId]: The product ID (used in file path)
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      // Generate unique filename
      final extension = imageFile.path.split('.').last;
      final fileName = '${productId}_${_uuid.v4()}.$extension';
      final filePath = 'products/$fileName';

      debugPrint('SupabaseService: Uploading product image - $filePath');

      // Upload the file
      await _client.storage
          .from(AppConstants.productImagesBucket)
          .upload(filePath, imageFile);

      // Get the public URL
      final publicUrl = _client.storage
          .from(AppConstants.productImagesBucket)
          .getPublicUrl(filePath);

      debugPrint('SupabaseService: Product image uploaded - $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('SupabaseService: Error uploading product image - $e');
      throw _handleStorageError(e, 'uploading product image');
    }
  }

  /// Uploads a product image from bytes (for web)
  Future<String> uploadProductImageBytes(
    Uint8List imageBytes,
    String productId,
    String extension,
  ) async {
    try {
      final fileName = '${productId}_${_uuid.v4()}.$extension';
      final filePath = 'products/$fileName';

      debugPrint('SupabaseService: Uploading product image bytes - $filePath');

      await _client.storage
          .from(AppConstants.productImagesBucket)
          .uploadBinary(filePath, imageBytes);

      final publicUrl = _client.storage
          .from(AppConstants.productImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('SupabaseService: Error uploading product image bytes - $e');
      throw _handleStorageError(e, 'uploading product image bytes');
    }
  }

  /// Deletes a product image from Supabase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final filePath = _extractFilePath(
        imageUrl,
        AppConstants.productImagesBucket,
      );

      if (filePath != null) {
        await _client.storage.from(AppConstants.productImagesBucket).remove([
          filePath,
        ]);

        debugPrint('SupabaseService: Product image deleted - $filePath');
      }
    } catch (e) {
      debugPrint('SupabaseService: Error deleting product image - $e');
      // Don't rethrow - deletion failure shouldn't break the flow
    }
  }

  // ===========================================================================
  // PROFILE IMAGES
  // ===========================================================================

  /// Uploads a user profile image to Supabase Storage
  ///
  /// Parameters:
  /// - [imageFile]: The image file to upload
  /// - [userId]: The user's UID (Firebase Auth UID)
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Generate unique filename using user ID
      final extension = imageFile.path.split('.').last;
      final fileName = '${userId}_${_uuid.v4()}.$extension';
      final filePath = 'profiles/$fileName';

      debugPrint('SupabaseService: Uploading profile image - $filePath');

      // Upload the file
      await _client.storage
          .from(AppConstants.profileImagesBucket)
          .upload(filePath, imageFile);

      // Get the public URL
      final publicUrl = _client.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(filePath);

      debugPrint('SupabaseService: Profile image uploaded - $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('SupabaseService: Error uploading profile image - $e');
      throw _handleStorageError(e, 'uploading profile image');
    }
  }

  /// Uploads a profile image from bytes (for web)
  Future<String> uploadProfileImageBytes(
    Uint8List imageBytes,
    String userId,
    String extension,
  ) async {
    try {
      final fileName = '${userId}_${_uuid.v4()}.$extension';
      final filePath = 'profiles/$fileName';

      debugPrint('SupabaseService: Uploading profile image bytes - $filePath');

      await _client.storage
          .from(AppConstants.profileImagesBucket)
          .uploadBinary(filePath, imageBytes);

      final publicUrl = _client.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('SupabaseService: Error uploading profile image bytes - $e');
      throw _handleStorageError(e, 'uploading profile image bytes');
    }
  }

  /// Deletes a user's profile image from Supabase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final filePath = _extractFilePath(
        imageUrl,
        AppConstants.profileImagesBucket,
      );

      if (filePath != null) {
        await _client.storage.from(AppConstants.profileImagesBucket).remove([
          filePath,
        ]);

        debugPrint('SupabaseService: Profile image deleted - $filePath');
      }
    } catch (e) {
      debugPrint('SupabaseService: Error deleting profile image - $e');
    }
  }

  /// Updates a user's profile image (deletes old, uploads new)
  Future<String> updateProfileImage(
    File newImageFile,
    String userId,
    String? oldImageUrl,
  ) async {
    try {
      // Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteProfileImage(oldImageUrl);
      }

      // Upload new image
      return await uploadProfileImage(newImageFile, userId);
    } catch (e) {
      debugPrint('SupabaseService: Error updating profile image - $e');
      rethrow;
    }
  }

  // ===========================================================================
  // GENERIC UPLOAD METHODS
  // ===========================================================================

  /// Uploads a file to a specified bucket
  Future<String> uploadFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = '$path/$fileName';

      await _client.storage.from(bucket).upload(filePath, file);

      return _client.storage.from(bucket).getPublicUrl(filePath);
    } catch (e) {
      debugPrint('SupabaseService: Error uploading file - $e');
      rethrow;
    }
  }

  /// Uploads bytes to a specified bucket
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String bucket,
    required String path,
    required String extension,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = '$path/$fileName';

      await _client.storage.from(bucket).uploadBinary(filePath, bytes);

      return _client.storage.from(bucket).getPublicUrl(filePath);
    } catch (e) {
      debugPrint('SupabaseService: Error uploading bytes - $e');
      rethrow;
    }
  }

  /// Deletes a file from a bucket
  Future<void> deleteFile(String bucket, String filePath) async {
    try {
      await _client.storage.from(bucket).remove([filePath]);
      debugPrint('SupabaseService: File deleted - $bucket/$filePath');
    } catch (e) {
      debugPrint('SupabaseService: Error deleting file - $e');
    }
  }

  // ===========================================================================
  // URL HELPERS
  // ===========================================================================

  /// Gets the public URL for a file in a bucket
  String getPublicUrl(String bucket, String filePath) {
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }

  /// Extracts the file path from a Supabase public URL
  String? _extractFilePath(String url, String bucket) {
    try {
      // URL format: https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      // Find the bucket in the path and return everything after it
      final bucketIndex = segments.indexOf(bucket);
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }

      return null;
    } catch (e) {
      debugPrint('SupabaseService: Error extracting file path - $e');
      return null;
    }
  }

  // ===========================================================================
  // LIST FILES
  // ===========================================================================

  /// Lists files in a bucket path
  Future<List<FileObject>> listFiles(String bucket, String path) async {
    try {
      final response = await _client.storage.from(bucket).list(path: path);
      return response;
    } catch (e) {
      debugPrint('SupabaseService: Error listing files - $e');
      return [];
    }
  }

  // ===========================================================================
  // DOWNLOAD
  // ===========================================================================

  /// Downloads a file as bytes
  Future<Uint8List?> downloadFile(String bucket, String filePath) async {
    try {
      final response = await _client.storage.from(bucket).download(filePath);
      return response;
    } catch (e) {
      debugPrint('SupabaseService: Error downloading file - $e');
      return null;
    }
  }

  // ===========================================================================
  // SIGNED URLS (for private buckets)
  // ===========================================================================

  /// Creates a signed URL with expiration (for private buckets)
  Future<String> createSignedUrl(
    String bucket,
    String filePath, {
    int expiresInSeconds = 3600,
  }) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .createSignedUrl(filePath, expiresInSeconds);
      return response;
    } catch (e) {
      debugPrint('SupabaseService: Error creating signed URL - $e');
      rethrow;
    }
  }
  // ===========================================================================
  // ERROR HANDLING
  // ===========================================================================

  /// Analyzes storage errors and returns a user-friendly exception
  SupabaseStorageException _handleStorageError(
      dynamic error, String operation) {
    String message = 'Failed to $operation';

    if (error is StorageException) {
      if (error.statusCode == '404') {
        message =
            'Storage bucket not found. Please ensure buckets are created in Supabase.';
      } else if (error.statusCode == '403') {
        message =
            'Access denied. Please check your Supabase Storage RLS policies.';
      } else if (error.statusCode == '413') {
        message = 'File is too large to upload.';
      } else if (error.message.contains('bucket not found')) {
        message =
            'Bucket not found. Ensure "product-images" and "profile-images" buckets exist.';
      } else {
        message = 'Supabase Storage error: ${error.message}';
      }
    } else {
      message = 'Unexpected storage error: $error';
    }

    return SupabaseStorageException(message);
  }
}

/// Custom exception for Supabase storage errors
class SupabaseStorageException implements Exception {
  final String message;

  SupabaseStorageException(this.message);

  @override
  String toString() => message;
}
