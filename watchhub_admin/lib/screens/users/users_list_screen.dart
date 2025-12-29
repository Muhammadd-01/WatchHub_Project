// =============================================================================
// FILE: users_list_screen.dart
// PURPOSE: List all registered users
// DESCRIPTION: Displays users and allows role management.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_user_provider.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Users',
      actions: [
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

          return Theme(
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
              columns: const [
                DataColumn2(label: Text('Name'), size: ColumnSize.L),
                DataColumn2(label: Text('Email'), size: ColumnSize.L),
                DataColumn2(label: Text('Role'), size: ColumnSize.S),
                DataColumn2(label: Text('Joined'), size: ColumnSize.M),
                DataColumn2(label: Text('Actions'), fixedWidth: 150),
              ],
              rows: users.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final role = data['role'] ?? 'customer';
                final isSuperAdmin = data['email'] == 'admin@watchhub.com';

                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryGold,
                          child: Text(
                            (data['name'] as String? ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.black,
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
                    DataCell(Text(DateFormat('MMM dd, yyyy').format(date),
                        style: AppTextStyles.bodyMedium)),
                    DataCell(isSuperAdmin
                        ? const Text('Super Admin',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic))
                        : Row(
                            children: [
                              // Promote/Demote
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
                                onPressed: () =>
                                    _toggleRole(context, doc.id, role),
                              ),
                              // Delete
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
  }

  void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'customer';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: const Text('Add New User', style: TextStyle(color: AppColors.textPrimary)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        DropdownMenuItem(value: 'customer', child: Text('Customer', style: TextStyle(color: AppColors.textPrimary))),
                        DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: AppColors.textPrimary))),
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
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: isLoading ? null : () async {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty || nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }

                    setState(() => isLoading = true);

                    // Create user via Secondary App
                    try {
                      FirebaseApp tempApp = await Firebase.initializeApp(
                        name: 'tempApp',
                        options: Firebase.app().options,
                      );
                      
                      try {
                        UserCredential cred = await FirebaseAuth.instanceFor(app: tempApp).createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        
                        // Create Firestore Doc (using main app instance)
                        if (cred.user != null) {
                          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'role': selectedRole,
                            'createdAt': FieldValue.serverTimestamp(),
                            'phone': '',
                          });
                        }
                        
                        await tempApp.delete();
                        if (context.mounted) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created successfully')));
                        }
                      } on FirebaseAuthException catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
                         }
                         await tempApp.delete();
                      }
                    } catch (e) {
                       if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          }
        );
      },
    );
  }
}
