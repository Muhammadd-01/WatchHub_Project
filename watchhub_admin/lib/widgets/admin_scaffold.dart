// =============================================================================
// FILE: admin_scaffold.dart
// PURPOSE: Main layout scaffold for Admin Panel
// DESCRIPTION: Provides responsive layout with sidebar and header.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

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
