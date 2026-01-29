// =============================================================================
// FILE: admin_scaffold.dart
// PURPOSE: Main layout scaffold for Admin Panel
// DESCRIPTION: Provides responsive layout with sidebar and header.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/admin_notification_provider.dart';
import '../../providers/admin_navigation_provider.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final isMobile = screenWidth <= 600;

    // Responsive padding
    final contentPadding = isMobile
        ? const EdgeInsets.all(12)
        : isTablet
            ? const EdgeInsets.all(16)
            : const EdgeInsets.all(24);

    return Column(
      children: [
        // Header
        _buildHeader(context, isDesktop, isMobile),

        // Main Content
        Expanded(
          child: Padding(
            padding: contentPadding,
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, bool isMobile) {
    return Container(
      height: isMobile ? 60 : 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Consumer<AdminNavigationProvider>(
                      builder: (context, nav, _) => IconButton(
                        icon: Icon(nav.isSidebarCollapsed
                            ? Icons.menu_open
                            : Icons.menu),
                        onPressed: () => nav.toggleSidebar(),
                        tooltip: nav.isSidebarCollapsed
                            ? 'Expand Sidebar'
                            : 'Collapse Sidebar',
                      ),
                    ),
                  ),
                if (Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Go Back',
                  ),
                if (Navigator.of(context).canPop()) const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: isMobile
                        ? AppTextStyles.titleLarge
                        : AppTextStyles.displaySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Notification Badge
                Consumer<AdminNotificationProvider>(
                  builder: (context, notificationProv, _) {
                    final count = notificationProv.unreadCount;
                    if (count == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Actions - wrap on mobile
          if (actions != null && actions!.isNotEmpty)
            isMobile
                ? actions!.length > 1
                    ? PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => actions!
                            .asMap()
                            .entries
                            .map((e) => PopupMenuItem(
                                  value: e.key,
                                  child: e.value,
                                ))
                            .toList(),
                      )
                    : Row(children: actions!)
                : Row(children: actions!),
        ],
      ),
    );
  }
}
