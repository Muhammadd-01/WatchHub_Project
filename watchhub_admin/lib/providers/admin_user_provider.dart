// =============================================================================
// FILE: admin_user_provider.dart
// PURPOSE: Manage Users (Promote, Demote, Delete)
// DESCRIPTION: Logic for user management with Super Admin protection.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AdminUserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Upload profile image to Supabase and return the public URL
  Future<String?> uploadProfileImage(XFile image) async {
    try {
      final fileName =
          'profiles/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final bytes = await image.readAsBytes();

      await _supabase.storage.from('profile-images').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: image.mimeType),
          );

      final url =
          _supabase.storage.from('profile-images').getPublicUrl(fileName);
      return url;
    } on StorageException catch (e) {
      String message = 'Supabase Storage error: ${e.message}';
      if (e.statusCode == '404') {
        message =
            'Bucket "profile-images" not found. Please create it in Supabase.';
      } else if (e.statusCode == '403') {
        message = 'Access denied to bucket. Check RLS policies.';
      }
      debugPrint('AdminUserProvider: $message');
      _errorMessage = message;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('AdminUserProvider: Unexpected error during upload - $e');
      _errorMessage = 'Failed to upload image: $e';
      notifyListeners();
      return null;
    }
  }

  // Promote user to admin
  Future<bool> updateUserRole(String uid, String newRole) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update role: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user
  Future<bool> deleteUser(String uid, String email) async {
    // PROTECT SUPER ADMIN
    if (email == 'admin@watchhub.com') {
      _errorMessage = 'Cannot delete Super Admin!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      // 1. Get user data to find profile image
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final profileImageUrl = data?['profileImageUrl'] as String?;

        // 2. Delete profile image from Supabase
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          try {
            // Extract file path from URL
            final uri = Uri.parse(profileImageUrl);
            final pathSegments = uri.pathSegments;
            final bucketIndex = pathSegments.indexOf('profile-images');
            if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
              final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
              await _supabase.storage.from('profile-images').remove([filePath]);
              debugPrint('Deleted profile image: $filePath');
            }
          } catch (e) {
            debugPrint('Failed to delete profile image from Supabase: $e');
            // Continue with user deletion
          }
        }
      }

      // 3. Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
