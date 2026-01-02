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
    // Basic responsive check
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Use a simple Column layout.
    // The overarching Scaffold comes from AdminMainScreen, unless this is a standalone page (like Login).
    // However, if we claim to be a "Scaffold", we should probably return a Scaffold
    // so things like Snackbars and FloatingActionButtons work if used here.
    // BUT AdminMainScreen already provides a Scaffold. Nested Scaffolds are okay,
    // but we want the drawer trigger to work.

    return Column(
      children: [
        // Header
        // In desktop, we always show header.
        // In mobile, we show AppBar.
        // Let's unify: We just render our custom header everywhere,
        // but on mobile add a "Menu" button if we are inside the Shell.
        _buildHeader(context, isDesktop),

        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              // Back Button (only if can pop AND we are not at root of shell?)
              // Since we are using IndexedStack, Navigator.canPop might be false for top level.
              // For detail pages pushed on top, it will be true.
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Go Back',
                ),
              if (Navigator.of(context).canPop()) const SizedBox(width: 8),

              Text(title, style: AppTextStyles.displaySmall),
            ],
          ),
          Row(
            children: actions ?? [],
          ),
        ],
      ),
    );
  }
}
