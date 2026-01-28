import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('About WatchHub', style: AppTextStyles.appBarTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/watchhub_logo_new.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'WatchHub',
              style: AppTextStyles.displaySmall.copyWith(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'WatchHub is your premier destination for luxury timepieces. We curate the finest collection of watches from world-renowned brands, ensuring that you find the perfect companion for your wrist.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.6, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 32),
            _buildInfoTile(
              context,
              'Terms of Service',
              Icons.description_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
            ),
            _buildInfoTile(
              context,
              'Privacy Policy',
              Icons.privacy_tip_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            ),
            _buildInfoTile(
              context,
              'Licenses',
              Icons.receipt_long_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.licenses),
            ),
            const SizedBox(height: 48),
            Text(
              '© 2024 WatchHub. All rights reserved.',
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.cardBorderLight,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGold),
        title: Text(title,
            style: AppTextStyles.bodyLarge
                .copyWith(color: theme.textTheme.bodyLarge?.color)),
        trailing: Icon(Icons.chevron_right, color: theme.disabledColor),
        onTap: onTap,
      ),
    );
  }
}
