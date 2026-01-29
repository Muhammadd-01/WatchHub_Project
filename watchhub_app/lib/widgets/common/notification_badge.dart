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
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              final count = notifProvider.unreadCount;
              if (count == 0) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.error, // Use red for better visibility
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
