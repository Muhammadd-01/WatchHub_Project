// =============================================================================
// FILE: edit_profile_screen.dart
// PURPOSE: Edit profile screen for WatchHub
// DESCRIPTION: Allows users to update their profile information and profile picture.
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // Image picking
  final _imagePicker = ImagePicker();
  File? _imageFile;
  final _supabaseService = SupabaseService();
  bool _isUploadingImage = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Failed to pick image');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            Helpers.showErrorSnackbar(context, 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted)
          Helpers.showErrorSnackbar(
              context, 'Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';

        setState(() {
          _addressController.text = address;
        });

        Helpers.showSuccessSnackbar(context, 'Location updated');
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) Helpers.showErrorSnackbar(context, 'Failed to get location');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    // Check if anything changed
    final nameChanged = _nameController.text.trim() != user.name;
    final phoneChanged = _phoneController.text.trim() != (user.phone ?? '');
    final addressChanged =
        _addressController.text.trim() != (user.address ?? '');
    final imageChanged = _imageFile != null;

    if (!nameChanged && !phoneChanged && !addressChanged && !imageChanged) {
      Navigator.pop(context);
      return;
    }

    // Upload image if changed
    String? newImageUrl;
    if (imageChanged) {
      setState(() => _isUploadingImage = true);
      try {
        newImageUrl = await _supabaseService.updateProfileImage(
          _imageFile!,
          user.uid,
          user.profileImageUrl,
        );
      } catch (e) {
        if (mounted) {
          String message = 'Failed to upload image';
          if (e.toString().contains('SocketException') ||
              e.toString().contains('ClientException') ||
              e.toString().contains('Failed host lookup')) {
            message = 'Network error: Please check your internet connection.';
          } else if (e is SupabaseStorageException) {
            message = e.message;
          }
          Helpers.showErrorSnackbar(context, message);
        }
        setState(() => _isUploadingImage = false);
        return;
      }
      setState(() => _isUploadingImage = false);
    }

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      profileImageUrl: newImageUrl,
    );

    if (success && mounted) {
      Helpers.showSuccessSnackbar(context, 'Profile updated successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('Edit Profile',
            style: AppTextStyles.appBarTitle
                .copyWith(color: theme.textTheme.titleLarge?.color)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture
              _buildProfilePicture(),
              const SizedBox(height: 32),

              // Form fields
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validatePhoneOptional,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your delivery address',
                      keyboardType: TextInputType.streetAddress,
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                      suffixIcon: IconButton(
                        icon: _isGettingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location,
                                color: AppColors.primaryGold),
                        onPressed:
                            _isGettingLocation ? null : _getCurrentLocation,
                        tooltip: 'Use my current location',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final isLoading = authProvider.isLoading || _isUploadingImage;
                  return LoadingButton(
                    onPressed: isLoading ? null : _saveProfile,
                    isLoading: isLoading,
                    text: 'Save Changes',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.read<AuthProvider>().user;
    final currentImageUrl = user?.profileImageUrl;

    // Determine image to show: Local file > Network URL > Initials
    Widget imageWidget;

    if (_imageFile != null) {
      imageWidget = Image.file(
        _imageFile!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: currentImageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildInitials(user),
      );
    } else {
      imageWidget = _buildInitials(user);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
              border: Border.all(
                color:
                    isDark ? AppColors.cardBorder : AppColors.cardBorderLight,
                width: 2,
              ),
            ),
            child: ClipOval(child: imageWidget),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardBackground
                    : AppColors.cardBackgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                onPressed: _pickImage,
                color: AppColors.primaryGold,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight,
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
