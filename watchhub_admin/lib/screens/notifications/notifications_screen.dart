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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Notifications',
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all),
          onPressed: () => _markAllAsRead(context),
          tooltip: 'Mark all as read',
        ),
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
              return _buildNotificationCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, String id, Map<String, dynamic> data) {
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
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.cardBackground
            : AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? AppColors.cardBorder
              : AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
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
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markAsRead(id),
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
