// =============================================================================
// FILE: users_list_screen.dart
// PURPOSE: List all registered users
// DESCRIPTION: Displays users and allows role management.
// =============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_user_provider.dart';
import '../../widgets/animated_reload_button.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedUserIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedUserIds.clear();
    });
  }

  void _toggleUserSelection(String uid) {
    setState(() {
      if (_selectedUserIds.contains(uid)) {
        _selectedUserIds.remove(uid);
      } else {
        _selectedUserIds.add(uid);
      }
    });
  }

  void _selectAll(List<QueryDocumentSnapshot> users) {
    setState(() {
      if (_selectedUserIds.length == users.length) {
        _selectedUserIds.clear();
      } else {
        _selectedUserIds.clear();
        for (var user in users) {
          _selectedUserIds.add(user.id);
        }
      }
    });
  }

  Future<void> _deleteSelected(List<QueryDocumentSnapshot> users) async {
    if (_selectedUserIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete ${_selectedUserIds.length} user(s)?',
            style: AppTextStyles.titleMedium),
        content: const Text(
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
      final provider = context.read<AdminUserProvider>();
      for (final uid in _selectedUserIds.toList()) {
        final email = users.firstWhere((u) => u.id == uid).get('email') ?? '';
        await provider.deleteUser(uid, email);
      }
      setState(() {
        _isSelectionMode = false;
        _selectedUserIds.clear();
      });
      if (mounted) {
        AdminHelpers.showSuccessSnackbar(context, 'Users deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode ? '${_selectedUserIds.length} Selected' : 'Users',
      actions: [
        // Selection mode toggle
        IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close : Icons.checklist,
            color: _isSelectionMode ? AppColors.error : AppColors.textPrimary,
            size: 20,
          ),
          tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Multiple',
          onPressed: _toggleSelectionMode,
        ),
        AnimatedReloadButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Users list refreshed'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.person_add, color: AppColors.primaryGold),
          onPressed: () => _showAddUserDialog(context),
          tooltip: 'Add User/Admin',
        ),
        const SizedBox(width: 16),
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;
          final isMobile = MediaQuery.of(context).size.width < 600;

          return Column(
            children: [
              // Selection action bar
              if (_isSelectionMode)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: AppColors.surfaceColor,
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _selectAll(users),
                        icon: Icon(
                          _selectedUserIds.length == users.length
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        label: Text(
                          _selectedUserIds.length == users.length
                              ? 'Deselect All'
                              : 'Select All',
                        ),
                      ),
                      const Spacer(),
                      if (_selectedUserIds.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _deleteSelected(users),
                          icon: const Icon(Icons.delete, size: 18),
                          label: Text('Delete (${_selectedUserIds.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: isMobile
                    ? ListView.builder(
                        itemCount: users.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) {
                          final doc = users[index];
                          final uid = doc.id;
                          final data = doc.data() as Map<String, dynamic>;
                          final date = data['createdAt'] != null
                              ? (data['createdAt'] as Timestamp).toDate()
                              : DateTime.now();
                          final role = data['role'] ?? 'customer';
                          final isSuperAdmin =
                              data['email'] == 'admin@watchhub.com';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: _isSelectionMode &&
                                    _selectedUserIds.contains(uid)
                                ? AppColors.primaryGold.withOpacity(0.1)
                                : AppColors.cardBackground,
                            child: InkWell(
                              onTap: _isSelectionMode && !isSuperAdmin
                                  ? () => _toggleUserSelection(uid)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Checkbox for selection
                                    if (_isSelectionMode && !isSuperAdmin)
                                      Checkbox(
                                        value: _selectedUserIds.contains(uid),
                                        onChanged: (_) =>
                                            _toggleUserSelection(uid),
                                        activeColor: AppColors.primaryGold,
                                      ),
                                    // Profile image
                                    data['profileImageUrl'] != null &&
                                            (data['profileImageUrl'] as String)
                                                .isNotEmpty
                                        ? CircleAvatar(
                                            radius: 24,
                                            backgroundImage: NetworkImage(
                                                data['profileImageUrl']),
                                            backgroundColor:
                                                AppColors.surfaceColor,
                                          )
                                        : CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                AppColors.primaryGold,
                                            child: Text(
                                              (data['name'] as String? ?? 'U')
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                    const SizedBox(width: 12),
                                    // User info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Unknown',
                                            style: AppTextStyles.titleSmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            data['email'] ?? '-',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: (role == 'admin')
                                                      ? AppColors.error
                                                          .withOpacity(0.2)
                                                      : AppColors.success
                                                          .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  role.toString().toUpperCase(),
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                    color: (role == 'admin')
                                                        ? AppColors.error
                                                        : AppColors.success,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(date),
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    if (isSuperAdmin)
                                      const Icon(Icons.shield,
                                          color: AppColors.primaryGold,
                                          size: 20)
                                    else
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'toggle':
                                              _toggleRole(
                                                  context, doc.id, role);
                                              break;
                                            case 'delete':
                                              _confirmDelete(context, doc.id,
                                                  data['email']);
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'toggle',
                                            child: Text(role == 'admin'
                                                ? 'Demote to Customer'
                                                : 'Promote to Admin'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete User'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: AppColors.cardBackground,
                          dividerColor: AppColors.divider,
                        ),
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 900,
                          headingRowColor: WidgetStateColor.resolveWith(
                              (states) => AppColors.surfaceColor),
                          columns: [
                            if (_isSelectionMode)
                              const DataColumn2(
                                  label: Text(''), fixedWidth: 50),
                            const DataColumn2(
                                label: Text('Name'), size: ColumnSize.L),
                            const DataColumn2(
                                label: Text('Email'), size: ColumnSize.L),
                            const DataColumn2(
                                label: Text('Role'), size: ColumnSize.S),
                            const DataColumn2(
                                label: Text('Joined'), size: ColumnSize.M),
                            const DataColumn2(
                                label: Text('Actions'), fixedWidth: 150),
                          ],
                          rows: users.map((doc) {
                            final uid = doc.id;
                            final data = doc.data() as Map<String, dynamic>;
                            final date = data['createdAt'] != null
                                ? (data['createdAt'] as Timestamp).toDate()
                                : DateTime.now();
                            final role = data['role'] ?? 'customer';
                            final isSuperAdmin =
                                data['email'] == 'admin@watchhub.com';

                            return DataRow(
                              selected: _selectedUserIds.contains(uid),
                              color: _selectedUserIds.contains(uid)
                                  ? WidgetStatePropertyAll(
                                      AppColors.primaryGold.withOpacity(0.1))
                                  : null,
                              cells: [
                                if (_isSelectionMode)
                                  DataCell(
                                    isSuperAdmin
                                        ? const SizedBox()
                                        : Checkbox(
                                            value:
                                                _selectedUserIds.contains(uid),
                                            onChanged: (_) =>
                                                _toggleUserSelection(uid),
                                            activeColor: AppColors.primaryGold,
                                          ),
                                  ),
                                DataCell(Row(
                                  children: [
                                    // Profile image or initials
                                    data['profileImageUrl'] != null &&
                                            (data['profileImageUrl'] as String)
                                                .isNotEmpty
                                        ? CircleAvatar(
                                            radius: 16,
                                            backgroundImage: NetworkImage(
                                                data['profileImageUrl']),
                                            backgroundColor:
                                                AppColors.surfaceColor,
                                          )
                                        : CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                AppColors.primaryGold,
                                            child: Text(
                                              (data['name'] as String? ?? 'U')
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                    const SizedBox(width: 8),
                                    Text(data['name'] ?? 'Unknown',
                                        style: AppTextStyles.bodyMedium),
                                  ],
                                )),
                                DataCell(Text(data['email'] ?? '-',
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (role == 'admin')
                                        ? AppColors.error.withOpacity(0.2)
                                        : AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(role.toString().toUpperCase(),
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: (role == 'admin')
                                              ? AppColors.error
                                              : AppColors.success)),
                                )),
                                DataCell(Text(
                                    DateFormat('MMM dd, yyyy').format(date),
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(isSuperAdmin
                                    ? const Text('Super Admin',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontStyle: FontStyle.italic))
                                    : Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              role == 'admin'
                                                  ? Icons.remove_moderator
                                                  : Icons.add_moderator,
                                              color: role == 'admin'
                                                  ? AppColors.warning
                                                  : AppColors.success,
                                            ),
                                            tooltip: role == 'admin'
                                                ? 'Demote to Customer'
                                                : 'Promote to Admin',
                                            onPressed: () => _toggleRole(
                                                context, doc.id, role),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: AppColors.error),
                                            tooltip: 'Delete User',
                                            onPressed: () => _confirmDelete(
                                                context, doc.id, data['email']),
                                          ),
                                        ],
                                      )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleRole(BuildContext context, String uid, String currentRole) {
    final newRole = currentRole == 'admin' ? 'customer' : 'admin';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Change Role',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to make this user a ${newRole.toUpperCase()}?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<AdminUserProvider>()
                  .updateUserRole(uid, newRole);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete User',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to delete $email? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AdminUserProvider>().deleteUser(uid, email);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'customer';
    bool isLoading = false;
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text('Add New User',
                style: TextStyle(color: AppColors.textPrimary)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Image Picker
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 512,
                          maxHeight: 512,
                        );
                        if (image != null) {
                          setState(() => selectedImage = image);
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceColor,
                          border: Border.all(
                            color: AppColors.primaryGold,
                            width: 2,
                          ),
                        ),
                        child: selectedImage != null
                            ? FutureBuilder<Uint8List>(
                                future: selectedImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ClipOval(
                                      child: Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    );
                                  }
                                  return const CircularProgressIndicator();
                                },
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      color: AppColors.primaryGold, size: 32),
                                  SizedBox(height: 4),
                                  Text('Add Photo',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: AppColors.cardBackground,
                      items: const [
                        DropdownMenuItem(
                            value: 'customer',
                            child: Text('Customer',
                                style:
                                    TextStyle(color: AppColors.textPrimary))),
                        DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin',
                                style:
                                    TextStyle(color: AppColors.textPrimary))),
                      ],
                      onChanged: (val) => setState(() => selectedRole = val!),
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            nameController.text.isEmpty) {
                          AdminHelpers.showErrorSnackbar(
                              context, 'Please fill all fields');
                          return;
                        }

                        setState(() => isLoading = true);

                        // Upload profile image if selected
                        String? profileImageUrl;
                        if (selectedImage != null) {
                          profileImageUrl = await context
                              .read<AdminUserProvider>()
                              .uploadProfileImage(selectedImage!);
                        }

                        // Create user via Secondary App
                        try {
                          FirebaseApp tempApp = await Firebase.initializeApp(
                            name: 'tempApp',
                            options: Firebase.app().options,
                          );

                          try {
                            UserCredential cred =
                                await FirebaseAuth.instanceFor(app: tempApp)
                                    .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            // Create Firestore Doc (using main app instance)
                            if (cred.user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(cred.user!.uid)
                                  .set({
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'role': selectedRole,
                                'createdAt': FieldValue.serverTimestamp(),
                                'phone': '',
                                'profileImageUrl': profileImageUrl ?? '',
                              });
                            }

                            await tempApp.delete();
                            if (context.mounted) {
                              Navigator.pop(context);
                              AdminHelpers.showSuccessSnackbar(
                                  context, 'User created successfully');
                            }
                          } on FirebaseAuthException catch (e) {
                            if (context.mounted) {
                              AdminHelpers.showErrorSnackbar(
                                  context, 'Error: ${e.message}');
                            }
                            await tempApp.delete();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AdminHelpers.showErrorSnackbar(
                                context, 'Error: $e');
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: const Text('Create User'),
              ),
            ],
          );
        });
      },
    );
  }
}
