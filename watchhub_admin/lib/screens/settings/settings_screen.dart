// =============================================================================
// FILE: settings_screen.dart
// PURPOSE: Admin Settings
// DESCRIPTION: Settings for theme, profile, and session management.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_auth_provider.dart';
import '../../providers/admin_theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              Consumer<AdminThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _buildSettingItem(
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark/light theme',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (val) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: AppColors.primaryGold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Account'),
              Consumer<AdminAuthProvider>(
                builder: (context, auth, _) {
                  return Column(
                    children: [
                      _buildSettingItem(
                        title: 'Email',
                        subtitle: auth.user?.email ?? 'Unknown',
                        icon: Icons.email_outlined,
                      ),
                      _buildSettingItem(
                        title: 'Role',
                        subtitle: auth.isAdmin ? 'Super Admin' : 'Admin',
                        icon: Icons.security,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'WatchHub Admin v1.0.0',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primaryGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    Widget? trailing,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: icon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryGold, size: 20),
              )
            : null,
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary))
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
