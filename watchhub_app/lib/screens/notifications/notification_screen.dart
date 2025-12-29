import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: Text('Notifications', style: AppTextStyles.appBarTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: notifications.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isRead
                        ? (isDark
                            ? AppColors.cardBackground
                            : AppColors.cardBackgroundLight)
                        : theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.cardBorder
                          : AppColors.cardBorderLight,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGold.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification['title'] as String,
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
                          notification['subtitle'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['time'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: theme.disabledColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
