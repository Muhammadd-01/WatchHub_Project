// =============================================================================
// FILE: profile_screen.dart
// PURPOSE: User profile screen for WatchHub
// DESCRIPTION: Displays user info and navigation to profile-related screens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/loading_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('Profile',
            style: AppTextStyles.appBarTitle
                .copyWith(color: theme.textTheme.titleLarge?.color)),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return _buildLoginPrompt(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(context, authProvider),
                const SizedBox(height: 24),
                _buildMenuSection(context),
                const SizedBox(height: 24),
                _buildLogoutButton(context, authProvider),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline,
                size: 80, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text('Sign in to your account', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Manage your orders, wishlist, and more',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LoadingButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              text: 'Sign In',
              width: 200,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              child: Text(
                'Create Account',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: user?.profileImageUrl != null &&
                    user!.profileImageUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user?.initials ?? 'U',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.scaffoldBackground,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'User', style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: AppTextStyles.bodyMedium),
                if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(user.phone!, style: AppTextStyles.bodySmall),
                ],
                if (user?.address != null && user!.address!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.address!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            style: IconButton.styleFrom(foregroundColor: AppColors.primaryGold),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'My Orders',
        'subtitle': 'View order history',
        'route': AppRoutes.orders,
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Wishlist',
        'subtitle': 'Saved products',
        'route': AppRoutes.wishlist,
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'subtitle': 'Theme, notifications',
        'route': AppRoutes.settings,
      },
      {
        'icon': Icons.feedback_outlined,
        'title': 'Send Feedback',
        'subtitle': 'Help us improve',
        'route': AppRoutes.feedback,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Contact us',
        'route': AppRoutes.help,
      },
      {
        'icon': Icons.info_outline,
        'title': 'About WatchHub',
        'subtitle': 'App info & policies',
        'route': AppRoutes.about,
      },
    ];

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: AppTextStyles.titleSmall,
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: AppTextStyles.bodySmall,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
                onTap: () {
                  final route = item['route'] as String?;
                  if (route != null) {
                    Navigator.pushNamed(context, route);
                  }
                },
              ),
              if (!isLast)
                Divider(height: 1, indent: 72, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return LoadingButton(
      onPressed: () => _showLogoutDialog(context, authProvider),
      text: 'Sign Out',
      outlined: true,
      icon: Icons.logout_rounded,
    ).animate().fadeIn(delay: 300.ms);
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Sign Out?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
