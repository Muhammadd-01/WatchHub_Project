import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTextStyles.appBarTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchHeader(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Common Questions'),
          _buildFAQItem(context, 'How do I track my order?',
              'You can track your order in the "Orders" section of your profile.'),
          _buildFAQItem(context, 'What is the return policy?',
              'We offer a 30-day return policy for all unworn watches in original packaging.'),
          _buildFAQItem(context, 'Are the watches authentic?',
              'Yes, all watches sold on WatchHub are 100% authentic and come with original warranty cards.'),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Contact Us'),
          _buildContactItem(context, 'Live Chat', 'Chat with our support team',
              Icons.chat_bubble_outline),
          _buildContactItem(context, 'Email Support', 'support@watchhub.com',
              Icons.email_outlined),
          _buildContactItem(
              context, 'Call Us', '+1 (800) 123-4567', Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'How can we help you?',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search help articles...',
              hintStyle: TextStyle(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.cardTheme.color,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
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
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, String title, String subtitle, IconData icon) {
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
            style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle,
            style: AppTextStyles.bodySmall
                .copyWith(color: theme.textTheme.bodyMedium?.color)),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.disabledColor),
        onTap: () {},
      ),
    );
  }
}
