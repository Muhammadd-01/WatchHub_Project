// =============================================================================
// FILE: notifications_screen.dart
// PURPOSE: Admin Notifications Screen
// DESCRIPTION: Shows notifications for user activities like feedback, reviews,
//              and order updates (cancelled, etc.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<QueryDocumentSnapshot> notifications) {
    setState(() {
      if (_selectedIds.length == notifications.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var doc in notifications) {
          _selectedIds.add(doc.id);
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Selected',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to delete ${_selectedIds.length} notifications?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in _selectedIds) {
        batch.delete(FirebaseFirestore.instance
            .collection('admin_notifications')
            .doc(id));
      }
      await batch.commit();
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications deleted')),
        );
      }
    }
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedIds.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedIds) {
      batch.update(
          FirebaseFirestore.instance.collection('admin_notifications').doc(id),
          {'isRead': true});
    }
    await batch.commit();
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected notifications marked as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode
          ? '${_selectedIds.length} Selected'
          : 'Notifications',
      actions: [
        if (_isSelectionMode) ...[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('admin_notifications')
                .orderBy('createdAt', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, snapshot) {
              final notifications = snapshot.data?.docs ?? [];
              return IconButton(
                onPressed: () => _selectAll(notifications),
                icon: Icon(
                  _selectedIds.length == notifications.length
                      ? Icons.deselect
                      : Icons.select_all,
                  size: 22,
                ),
                tooltip: _selectedIds.length == notifications.length
                    ? 'Deselect All'
                    : 'Select All',
                color: AppColors.primaryGold,
              );
            },
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _markSelectedAsRead,
            icon: const Icon(Icons.done, size: 22),
            tooltip: 'Mark Selected as Read',
            color: _selectedIds.isEmpty
                ? AppColors.textSecondary
                : AppColors.success,
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            icon: const Icon(Icons.delete_sweep, size: 22),
            tooltip: 'Delete Selected',
            color: _selectedIds.isEmpty
                ? AppColors.textSecondary
                : AppColors.error,
          ),
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.close, size: 22),
            tooltip: 'Cancel',
            color: AppColors.error,
          ),
        ] else ...[
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.checklist, size: 20),
            tooltip: 'Select Multiple',
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(context),
            tooltip: 'Mark all as read',
          ),
        ],
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_notifications')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notifications',
                  style: TextStyle(color: AppColors.error)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No notifications yet',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'User activities will appear here',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = _selectedIds.contains(doc.id);
              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(doc.id);
                  }
                },
                onTap: _isSelectionMode ? () => _toggleSelection(doc.id) : null,
                child:
                    _buildNotificationCard(context, doc.id, data, isSelected),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, String id,
      Map<String, dynamic> data, bool isSelected) {
    final type = data['type'] ?? 'general';
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final isRead = data['isRead'] ?? false;
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy HH:mm').format(createdAt.toDate())
        : 'Unknown';

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'feedback':
        icon = Icons.feedback_outlined;
        iconColor = AppColors.info;
        break;
      case 'review':
        icon = Icons.rate_review_outlined;
        iconColor = AppColors.warning;
        break;
      case 'order_cancelled':
        icon = Icons.cancel_outlined;
        iconColor = AppColors.error;
        break;
      case 'order_placed':
        icon = Icons.shopping_bag_outlined;
        iconColor = AppColors.success;
        break;
      case 'order_completed':
        icon = Icons.check_circle_outline;
        iconColor = AppColors.success;
        break;
      case 'restock_alert':
        icon = Icons.inventory_2_outlined;
        iconColor = AppColors.error;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryGold.withOpacity(0.2)
            : (isRead
                ? AppColors.cardBackground
                : AppColors.primaryGold.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryGold
              : (isRead
                  ? AppColors.cardBorder
                  : AppColors.primaryGold.withOpacity(0.3)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(id),
                activeColor: AppColors.primaryGold,
              ),
            ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              title: Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateStr,
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              trailing: !isRead && !isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: _isSelectionMode
                  ? () => _toggleSelection(id)
                  : () => _markAsRead(id),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('admin_notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    final batch = FirebaseFirestore.instance.batch();
    final notifications = await FirebaseFirestore.instance
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
