// =============================================================================
// FILE: settings_screen.dart
// PURPOSE: Application settings screen
// DESCRIPTION: Allows users to configure app preferences like Theme, Notifications, etc.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.appBarTitle.copyWith(color: textColor),
        ),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader(context, 'Appearance'),
            _buildThemeCard(context, isDark, cardColor, textColor),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Notifications'),
            _buildNotificationCard(context, cardColor, textColor),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildAboutCard(context, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context, bool isDark, Color? cardColor, Color? textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.cardBorderLight,
        ),
      ),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SwitchListTile(
            title: Text(
              'Dark Mode',
              style: AppTextStyles.bodyLarge.copyWith(color: textColor),
            ),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark theme enabled'
                  : 'Light theme enabled',
              style: AppTextStyles.bodySmall,
            ),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Theme.of(context).primaryColor,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            activeColor: AppColors.primaryGold,
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, Color? cardColor, Color? textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Push Notifications',
              style: AppTextStyles.bodyLarge.copyWith(color: textColor),
            ),
            value: true, // Placeholder
            onChanged: (val) {},
            activeColor: AppColors.primaryGold,
            secondary: Icon(Icons.notifications_outlined,
                color: Theme.of(context).primaryColor),
          ),
          Divider(
            color: isDark ? AppColors.divider : AppColors.dividerLight,
            height: 1,
          ),
          SwitchListTile(
            title: Text(
              'Order Updates',
              style: AppTextStyles.bodyLarge.copyWith(color: textColor),
            ),
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.primaryGold,
            secondary: Icon(Icons.local_shipping_outlined,
                color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
      BuildContext context, Color? cardColor, Color? textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.cardBorderLight,
        ),
      ),
      child: ListTile(
        leading:
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
        title: Text('Version',
            style: AppTextStyles.bodyLarge.copyWith(color: textColor)),
        trailing: Text('1.0.0',
            style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
      ),
    );
  }
}
