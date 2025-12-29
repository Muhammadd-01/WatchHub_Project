// =============================================================================
// FILE: forgot_password_screen.dart
// PURPOSE: Password reset screen for WatchHub
// DESCRIPTION: Allows users to reset their password via email.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _emailSent = true);
      Helpers.showSuccessSnackbar(
        context,
        'Password reset email sent successfully!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 48),
              if (_emailSent) _buildSuccessMessage() else _buildForm(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.primaryGold, width: 2),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: AppColors.primaryGold,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fadeIn(),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          style: AppTextStyles.headlineLarge,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a link to reset your password',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return LoadingButton(
              onPressed: _handleResetPassword,
              isLoading: authProvider.isLoading,
              text: 'Send Reset Link',
            );
          },
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text('Email Sent!', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Check your inbox for a password reset link. If you don\'t see it, check your spam folder.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Back to Login',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
