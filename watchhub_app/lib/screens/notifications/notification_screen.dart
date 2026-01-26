import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_crud_service.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirestoreCrudService _firestoreService = FirestoreCrudService();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _clearAllNotifications(String uid) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Clear All Notifications',
      message: 'Are you sure you want to delete all notifications?',
      confirmText: 'Clear All',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      try {
        await _firestoreService.clearAllNotifications(uid);
        if (mounted) {
          Helpers.showSuccessSnackbar(context, 'All notifications cleared');
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackbar(context, 'Failed to clear notifications');
        }
      }
    }
  }

  Future<void> _onNotificationTap(
      String uid, Map<String, dynamic> notification) async {
    // Navigate to detail screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailScreen(notification: notification),
      ),
    );

    // Mark as read after returning
    final notificationId = notification['id'] as String?;
    if (notificationId != null) {
      await _firestoreService.markNotificationRead(uid, notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refreshKey.currentState?.show();
            },
          ),
          // Clear all button
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.uid == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear All',
                onPressed: () => _clearAllNotifications(auth.uid!),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user == null) {
            return const Center(
                child: Text('Please log in to view notifications'));
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.notificationsStream(auth.uid!),
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

              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: () async {
                  // StreamBuilder auto-refreshes, but this gives visual feedback
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
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
                    if (title.contains('Shipped')) {
                      icon = Icons.local_shipping_outlined;
                    } else if (title.contains('Approved')) {
                      icon = Icons.check_circle_outline;
                    } else if (title.contains('Delivered')) {
                      icon = Icons.check_circle;
                    } else if (title.contains('Cancelled')) {
                      icon = Icons.cancel_outlined;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isRead
                            ? theme.cardColor.withOpacity(0.5) // Dim for read
                            : theme.colorScheme.primaryContainer
                                .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead
                              ? theme.dividerColor.withOpacity(0.5)
                              : AppColors.primaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRead
                                ? theme.primaryColor.withOpacity(0.05)
                                : theme.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            icon,
                            color: isRead
                                ? theme.primaryColor.withOpacity(0.5)
                                : theme.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            color: isRead
                                ? theme.textTheme.titleMedium?.color
                                    ?.withOpacity(0.6)
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isRead
                                    ? theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.4)
                                    : theme.textTheme.bodyMedium?.color
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
                        trailing: !isRead
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryGold,
                                ),
                              )
                            : null,
                        onTap: () =>
                            _onNotificationTap(auth.uid!, notification),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
