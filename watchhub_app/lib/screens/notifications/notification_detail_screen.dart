// =============================================================================
// FILE: notification_detail_screen.dart
// PURPOSE: Shows details of a single notification
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = notification['title'] as String? ?? 'Notification';
    final message = notification['message'] as String? ?? '';
    final time = notification['createdAt'] is DateTime
        ? Helpers.formatDateTime(notification['createdAt'] as DateTime)
        : 'Unknown time';

    // Determine icon based on title
    IconData icon = Icons.notifications_outlined;
    Color iconColor = theme.primaryColor;
    if (title.contains('Shipped')) {
      icon = Icons.local_shipping_outlined;
      iconColor = Colors.indigo;
    } else if (title.contains('Approved')) {
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else if (title.contains('Delivered')) {
      icon = Icons.check_circle;
      iconColor = Colors.teal;
    } else if (title.contains('Cancelled')) {
      icon = Icons.cancel_outlined;
      iconColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notification',
            style: AppTextStyles.appBarTitle.copyWith(
              color: theme.textTheme.titleLarge?.color,
            )),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Time
            Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: theme.dividerColor),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
