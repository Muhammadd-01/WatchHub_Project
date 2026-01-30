import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Color? iconColor;

  const NotificationBadge({
    super.key,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, child) {
        final count = notifProvider.unreadCount;

        return IconButton(
          icon: Badge(
            label: Text(count > 9 ? '9+' : count.toString()),
            isLabelVisible: count > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: Icon(
              Icons.notifications_outlined,
              color: iconColor ?? Theme.of(context).iconTheme.color,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
        );
      },
    );
  }
}
