import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AppLicensePage extends StatelessWidget {
  const AppLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Licenses'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Open Source Licenses',
                style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 16),
            Text(
              'WatchHub is built using the following open source packages:',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 24),
            _buildLicenseItem(context, 'Flutter',
                'BSD-3-Clause License\nCopyright 2014 The Flutter Authors'),
            _buildLicenseItem(context, 'Firebase',
                'Apache License 2.0\nCopyright Google LLC'),
            _buildLicenseItem(context, 'Supabase',
                'Apache License 2.0\nCopyright Supabase Inc.'),
            _buildLicenseItem(
                context, 'Provider', 'MIT License\nCopyright Remi Rousselet'),
            _buildLicenseItem(context, 'Cached Network Image',
                'MIT License\nCopyright Baseflow'),
            _buildLicenseItem(context, 'Share Plus',
                'BSD-3-Clause License\nCopyright The Flutter Community'),
            const Divider(height: 32),
            Text(
              'For full license texts, see each package\'s repository.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseItem(BuildContext context, String name, String license) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackground
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(license,
              style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service',
                style: AppTextStyles.titleLarge.copyWith(color: textColor)),
            const SizedBox(height: 8),
            Text('Last updated: January 2024',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(height: 24),
            _buildSection(context, '1. Acceptance of Terms',
                'By accessing and using WatchHub, you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, you should not use this application.'),
            _buildSection(context, '2. Use of Service',
                'WatchHub provides a platform for browsing and purchasing luxury watches. You agree to use the service only for lawful purposes and in accordance with these terms.'),
            _buildSection(context, '3. User Accounts',
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to accept responsibility for all activities that occur under your account.'),
            _buildSection(context, '4. Product Information',
                'We strive to provide accurate product descriptions and pricing. However, we do not warrant that product descriptions or prices are error-free. We reserve the right to correct any errors.'),
            _buildSection(context, '5. Order Acceptance',
                'Your order is an offer to purchase. We reserve the right to accept or decline your order for any reason, including product availability, pricing errors, or verification issues.'),
            _buildSection(context, '6. Payment Terms',
                'All payments must be made through our approved payment methods. Prices are in USD unless otherwise specified. You agree to pay all charges incurred through your account.'),
            _buildSection(context, '7. Shipping & Delivery',
                'Delivery times are estimates only. We are not responsible for delays caused by shipping carriers or customs processing.'),
            _buildSection(context, '8. Returns & Refunds',
                'Returns are accepted within 30 days of delivery for unworn items in original packaging. Custom orders are non-refundable.'),
            _buildSection(context, '9. Limitation of Liability',
                'WatchHub shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.'),
            _buildSection(context, '10. Contact Us',
                'For questions about these Terms, contact us at support@watchhub.com.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: textColor, height: 1.5)),
        ],
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy',
                style: AppTextStyles.titleLarge.copyWith(color: textColor)),
            const SizedBox(height: 8),
            Text('Last updated: January 2024',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(height: 24),
            _buildSection(context, '1. Information We Collect',
                'We collect personal information you provide (name, email, address, payment details) and usage data (browsing history, device information, location data).'),
            _buildSection(context, '2. How We Use Your Information',
                'We use your data to:\n• Process orders and payments\n• Send order updates and notifications\n• Personalize your shopping experience\n• Improve our products and services\n• Prevent fraud and ensure security'),
            _buildSection(context, '3. Data Sharing',
                'We may share data with:\n• Payment processors (Stripe, PayPal)\n• Shipping carriers\n• Analytics providers\n• Law enforcement (when required by law)'),
            _buildSection(context, '4. Data Security',
                'We implement industry-standard security measures including encryption, secure servers, and regular security audits to protect your personal information.'),
            _buildSection(context, '5. Your Rights',
                'You have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Request data deletion\n• Opt out of marketing communications\n• Export your data'),
            _buildSection(context, '6. Cookies',
                'We use cookies and similar technologies to enhance your experience, analyze trends, and administer the app. You can control cookies through your device settings.'),
            _buildSection(context, '7. Third-Party Links',
                'Our app may contain links to third-party websites. We are not responsible for their privacy practices.'),
            _buildSection(context, '8. Children\'s Privacy',
                'Our service is not directed to children under 13. We do not knowingly collect personal information from children.'),
            _buildSection(context, '9. Changes to Policy',
                'We may update this policy periodically. We will notify you of significant changes via email or in-app notification.'),
            _buildSection(context, '10. Contact Us',
                'For privacy-related questions, contact us at privacy@watchhub.com.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: textColor, height: 1.5)),
        ],
      ),
    );
  }
}
