// =============================================================================
// FILE: admin_profile_screen.dart
// PURPOSE: Admin Profile Screen
// DESCRIPTION: Shows and allows editing of admin profile information with
//              profile image upload, update, and removal functionality.
// =============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_auth_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AdminAuthProvider>();
    _nameController = TextEditingController(text: auth.adminName ?? 'Admin');
    _emailController = TextEditingController(text: auth.adminEmail ?? '');
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final auth = context.read<AdminAuthProvider>();
    if (auth.userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.userId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _currentProfileImageUrl = doc.data()?['profileImageUrl'];
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final auth = context.read<AdminAuthProvider>();
      final supabase = Supabase.instance.client;

      // Generate unique filename
      final fileName =
          'admin/${auth.userId}_${DateTime.now().millisecondsSinceEpoch}.${_selectedImage!.name.split('.').last}';
      final bytes = await _selectedImage!.readAsBytes();

      // Upload to Supabase
      await supabase.storage.from('profile-images').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: _selectedImage!.mimeType),
          );

      // Get public URL
      final url =
          supabase.storage.from('profile-images').getPublicUrl(fileName);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.userId)
          .update({'profileImageUrl': url});

      if (mounted) {
        setState(() {
          _currentProfileImageUrl = url;
          _selectedImage = null;
          _selectedImageBytes = null;
        });
        AdminHelpers.showSuccessSnackbar(context, 'Profile image updated');
      }
    } catch (e) {
      if (mounted) {
        AdminHelpers.showErrorSnackbar(context, 'Failed to upload image: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _removeProfileImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final auth = context.read<AdminAuthProvider>();

      // Update Firestore to remove image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.userId)
          .update({'profileImageUrl': ''});

      if (mounted) {
        setState(() {
          _currentProfileImageUrl = null;
          _selectedImage = null;
          _selectedImageBytes = null;
        });
        AdminHelpers.showSuccessSnackbar(context, 'Profile image removed');
      }
    } catch (e) {
      if (mounted) {
        AdminHelpers.showErrorSnackbar(context, 'Failed to remove image');
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<AdminAuthProvider>().updateProfile(
            name: _nameController.text.trim(),
          );

      // Also upload image if selected
      if (_selectedImage != null) {
        await _uploadProfileImage();
      }

      if (mounted) {
        AdminHelpers.showSuccessSnackbar(context, 'Profile updated');
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        AdminHelpers.showErrorSnackbar(context, 'Failed to update profile');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Profile',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Consumer<AdminAuthProvider>(
            builder: (context, auth, _) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image with Edit Options
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _isEditing ? _pickImage : null,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryGold,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: _isUploadingImage
                                    ? Container(
                                        color: AppColors.surfaceColor,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primaryGold,
                                          ),
                                        ),
                                      )
                                    : _selectedImageBytes != null
                                        ? Image.memory(
                                            _selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : _currentProfileImageUrl != null &&
                                                _currentProfileImageUrl!
                                                    .isNotEmpty
                                            ? Image.network(
                                                _currentProfileImageUrl!,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildInitialsAvatar(
                                                        auth.adminName ?? 'A'),
                                              )
                                            : _buildInitialsAvatar(
                                                auth.adminName ?? 'A'),
                              ),
                            ),
                          ),
                          // Edit badge
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.scaffoldBackground,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Image action buttons (when editing)
                      if (_isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_photo_alternate,
                                  size: 18),
                              label: Text(_currentProfileImageUrl != null
                                  ? 'Change'
                                  : 'Add Photo'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGold,
                              ),
                            ),
                            if (_currentProfileImageUrl != null &&
                                _currentProfileImageUrl!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _removeProfileImage,
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Remove'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle:
                              const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.primaryGold),
                          filled: true,
                          fillColor: AppColors.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.divider, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primaryGold, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email (read-only)
                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7)),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:
                              const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surfaceColor.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      if (_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _selectedImage = null;
                                    _selectedImageBytes = null;
                                  });
                                  _nameController.text =
                                      auth.adminName ?? 'Admin';
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(
                                      color: AppColors.divider),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Reset Password button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final email = auth.adminEmail;
                            if (email != null && email.isNotEmpty) {
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);
                                if (mounted) {
                                  AdminHelpers.showSuccessSnackbar(
                                    context,
                                    'Password reset email sent to $email',
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  AdminHelpers.showErrorSnackbar(
                                    context,
                                    'Failed to send reset email',
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.lock_reset,
                              color: AppColors.primaryGold),
                          label: const Text('Reset Password',
                              style: TextStyle(color: AppColors.primaryGold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side:
                                const BorderSide(color: AppColors.primaryGold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<AdminAuthProvider>().signOut();
                          },
                          icon:
                              const Icon(Icons.logout, color: AppColors.error),
                          label: const Text('Sign Out',
                              style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        gradient: AppColors.goldGradient,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: AppTextStyles.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
