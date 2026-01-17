import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredFAQs = [];

  final List<Map<String, String>> _allFAQs = [
    {
      'question': 'How do I track my order?',
      'answer':
          'You can track your order in the "Orders" section of your profile.'
    },
    {
      'question': 'What is the return policy?',
      'answer':
          'We offer a 30-day return policy for all unworn watches in original packaging.'
    },
    {
      'question': 'Are the watches authentic?',
      'answer':
          'Yes, all watches sold on WatchHub are 100% authentic and come with original warranty cards.'
    },
    {
      'question': 'How long does shipping take?',
      'answer':
          'Standard shipping takes 3-5 business days. Express shipping is 1-2 business days.'
    },
    {
      'question': 'Do you offer warranty?',
      'answer':
          'Yes, all watches come with manufacturer warranty. Extended warranty options are available.'
    },
    {
      'question': 'How do I cancel my order?',
      'answer':
          'You can cancel your order within 24 hours of placing it from the Orders section.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _allFAQs;
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs = _allFAQs
            .where((faq) =>
                faq['question']!.toLowerCase().contains(query.toLowerCase()) ||
                faq['answer']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@watchhub.com',
      queryParameters: {
        'subject': 'WatchHub Support Request',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+923160212457');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    // WhatsApp number: 03160212457 (Pakistan format -> +923160212457)
    final Uri whatsappUri =
        Uri.parse('https://wa.me/923160212457?text=Hello%20WatchHub%20Support');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          if (_filteredFAQs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No results found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            )
          else
            ..._filteredFAQs.map((faq) =>
                _buildFAQItem(context, faq['question']!, faq['answer']!)),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Contact Us'),
          _buildContactItem(
            context,
            'Live Chat',
            'Chat with us on WhatsApp',
            Icons.chat_bubble_outline,
            onTap: _launchWhatsApp,
          ),
          _buildContactItem(
            context,
            'Email Support',
            'support@watchhub.com',
            Icons.email_outlined,
            onTap: _launchEmail,
          ),
          _buildContactItem(
            context,
            'Call Us',
            '+92 316 021 2457',
            Icons.phone_outlined,
            onTap: _launchPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
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
            controller: _searchController,
            onChanged: _filterFAQs,
            decoration: InputDecoration(
              hintText: 'Search help articles...',
              hintStyle: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterFAQs('');
                      },
                    )
                  : null,
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
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, String title, String subtitle, IconData icon,
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
            style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle,
            style: AppTextStyles.bodySmall
                .copyWith(color: theme.textTheme.bodyMedium?.color)),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.disabledColor),
        onTap: onTap,
      ),
    );
  }
}
