import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_crud_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy notifications for demo
    final notifications = [
      {
        'title': 'Order Shipped',
        'subtitle': 'Your Rolex Submariner has been shipped.',
        'time': '2 hrs ago',
        'isRead': false,
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'New Arrival',
        'subtitle': 'Check out the new Patek Philippe collection.',
        'time': '5 hrs ago',
        'isRead': true,
        'icon': Icons.new_releases_outlined,
      },
      {
        'title': 'Exclusive Offer',
        'subtitle': 'Get 10% off on your next purchase.',
        'time': '1 day ago',
        'isRead': true,
        'icon': Icons.local_offer_outlined,
      },
      {
        'title': 'Security Alert',
        'subtitle': 'New login detected from a new device.',
        'time': '2 days ago',
        'isRead': true,
        'icon': Icons.security_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notifications',
            style: AppTextStyles.appBarTitle.copyWith(
              color: theme.textTheme.titleLarge?.color,
            )),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user == null) {
            return const Center(
                child: Text('Please log in to view notifications'));
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreCrudService().notificationsStream(auth.uid!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['read'] as bool? ?? false;
                  final title =
                      notification['title'] as String? ?? 'Notification';
                  final message = notification['message'] as String? ?? '';
                  final time = notification['createdAt'] is DateTime
                      ? Helpers.formatRelativeTime(
                          notification['createdAt'] as DateTime)
                      : 'Just now';

                  IconData icon = Icons.notifications_outlined;
                  if (title.contains('Shipped'))
                    icon = Icons.local_shipping_outlined;
                  else if (title.contains('Approved'))
                    icon = Icons.check_circle_outline;
                  else if (title.contains('Delivered'))
                    icon = Icons.check_circle;
                  else if (title.contains('Cancelled'))
                    icon = Icons.cancel_outlined;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isRead
                          ? theme.cardColor
                          : theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          icon,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        title,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: theme.disabledColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Mark as read logic
                        FirestoreCrudService().markNotificationRead(
                            auth.uid!, notification['id']);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
