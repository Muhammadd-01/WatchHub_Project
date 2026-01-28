// =============================================================================
// FILE: brands_screen.dart
// PURPOSE: Admin Brands Management Screen
// DESCRIPTION: Allows admin to add, edit, and delete watch brands.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isSelectionMode = false;
  final Set<String> _selectedBrandIds = {};

  // For image upload
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedBrandIds.clear();
    });
  }

  void _toggleBrandSelection(String id) {
    setState(() {
      if (_selectedBrandIds.contains(id)) {
        _selectedBrandIds.remove(id);
      } else {
        _selectedBrandIds.add(id);
      }
    });
  }

  /// Pick a logo image from device
  Future<XFile?> _pickLogoImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Upload logo to Supabase and return URL
  Future<String?> _uploadLogoToSupabase(XFile file, String brandName) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName =
          '${brandName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.${file.name.split('.').last}';

      final supabase = Supabase.instance.client;
      await supabase.storage.from('brand-images').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl =
          supabase.storage.from('brand-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading logo: $e');
      return null;
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedBrandIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete ${_selectedBrandIds.length} brand(s)?',
            style: AppTextStyles.titleMedium),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final batch = _firestore.batch();
      for (final id in _selectedBrandIds) {
        batch.delete(_firestore.collection('brands').doc(id));
      }
      await batch.commit();
      setState(() {
        _selectedBrandIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Brands deleted'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAddEditDialog([DocumentSnapshot? brand]) async {
    XFile? selectedImage;
    String? existingLogoUrl;
    bool isUploadingInDialog = false;

    if (brand != null) {
      final data = brand.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _logoUrlController.text = data['logoUrl'] ?? '';
      existingLogoUrl = data['logoUrl'] as String?;
    } else {
      _nameController.clear();
      _logoUrlController.clear();
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            brand != null ? 'Edit Brand' : 'Add Brand',
            style: AppTextStyles.titleMedium,
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Brand Name *',
                      hintText: 'e.g., Rolex, Omega',
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    validator: (value) => value?.isEmpty == true
                        ? 'Brand name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Logo preview and picker
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Preview
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.textTertiary.withOpacity(0.3)),
                          ),
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                          selectedImage!.path,
                                          fit: BoxFit.contain,
                                        )
                                      : FutureBuilder<dynamic>(
                                          future: selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.contain,
                                              );
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                )
                              : existingLogoUrl != null &&
                                      existingLogoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: existingLogoUrl,
                                        fit: BoxFit.contain,
                                        errorWidget: (_, __, ___) => Icon(
                                          Icons.image,
                                          size: 40,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: 40,
                                      color: AppColors.textTertiary,
                                    ),
                        ),
                        const SizedBox(height: 12),
                        // Pick image button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final image = await _pickLogoImage();
                            if (image != null) {
                              setDialogState(() {
                                selectedImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload, size: 18),
                          label: Text(selectedImage != null
                              ? 'Change Logo'
                              : 'Upload Logo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceColor,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                        if (selectedImage != null)
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                selectedImage = null;
                              });
                            },
                            child: Text('Remove',
                                style: TextStyle(color: AppColors.error)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // OR divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: AppColors.textTertiary.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR',
                            style: TextStyle(color: AppColors.textTertiary)),
                      ),
                      Expanded(
                          child: Divider(
                              color: AppColors.textTertiary.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Manual URL field
                  TextFormField(
                    controller: _logoUrlController,
                    decoration: InputDecoration(
                      labelText: 'Logo URL (paste link)',
                      hintText: 'https://...',
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    enabled: selectedImage == null,
                  ),

                  if (isUploadingInDialog)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploadingInDialog
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'selectedImage': selectedImage,
                          'confirmed': true,
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
              ),
              child: Text(brand != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['confirmed'] == true) {
      String? logoUrl = _logoUrlController.text.trim();
      final pickedImage = result['selectedImage'] as XFile?;

      // Upload to Supabase if image was picked
      if (pickedImage != null) {
        setState(() => _isUploading = true);
        final uploadedUrl = await _uploadLogoToSupabase(
          pickedImage,
          _nameController.text.trim(),
        );
        setState(() => _isUploading = false);

        if (uploadedUrl != null) {
          logoUrl = uploadedUrl;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Failed to upload logo. Using existing URL if available.'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (brand != null) {
        await _firestore.collection('brands').doc(brand.id).update(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Brand updated'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('brands').add(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Brand added'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteBrand(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete Brand?', style: AppTextStyles.titleMedium),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('brands').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Brand deleted'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage Brands',
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              // Will be called with brands list from StreamBuilder
            },
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _selectedBrandIds.isNotEmpty ? _deleteSelected : null,
            tooltip: 'Delete Selected',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSelectionMode,
            tooltip: 'Cancel',
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: _toggleSelectionMode,
            tooltip: 'Select Multiple',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add Brand',
          ),
        ],
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('brands').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: AppColors.error)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
          }

          final brands = snapshot.data?.docs ?? [];

          if (brands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.branding_watermark_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No brands yet', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Add brands to use in products',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Brand'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final data = brand.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final logoUrl = data['logoUrl'] ?? '';
              final isSelected = _selectedBrandIds.contains(brand.id);

              return GestureDetector(
                onTap: _isSelectionMode
                    ? () => _toggleBrandSelection(brand.id)
                    : () => _showAddEditDialog(brand),
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleBrandSelection(brand.id);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold.withOpacity(0.2)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_isSelectionMode)
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleBrandSelection(brand.id),
                          activeColor: AppColors.primaryGold,
                        ),
                      if (logoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: logoUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.surfaceColor,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.surfaceColor,
                              child: const Icon(Icons.watch,
                                  color: AppColors.textTertiary),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          name.toUpperCase(),
                          style: AppTextStyles.titleSmall.copyWith(
                            letterSpacing: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isSelectionMode)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert,
                              color: AppColors.textSecondary),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(brand);
                            } else if (value == 'delete') {
                              _deleteBrand(brand.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
