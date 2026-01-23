// =============================================================================
// FILE: signup_screen.dart
// PURPOSE: Signup screen for WatchHub
// DESCRIPTION: Premium registration UI with email/password signup.
//              Creates Firebase Auth user AND Firestore user document.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

/// Signup screen with premium design
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else if (!success && mounted && authProvider.errorMessage != null) {
      _handleError(authProvider.errorMessage!);
    }
  }

  Future<void> _handleSocialSignup(String provider) async {
    final authProvider = context.read<AuthProvider>();

    try {
      bool success = false;
      if (provider == 'google') {
        success = await authProvider.signInWithGoogle();
      } else if (provider == 'facebook') {
        success = await authProvider.signInWithFacebook();
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      } else if (!success && mounted && authProvider.errorMessage != null) {
        _handleError(authProvider.errorMessage!);
      }
    } catch (e) {
      if (mounted) _handleError(e.toString());
    }
  }

  void _handleError(String message) {
    if (message.toLowerCase().contains('cancel') ||
        message.toLowerCase().contains('interrupted')) {
      // Ignore cancelations silently or log them
      debugPrint('SignupScreen: Google Sign-In canceled by user');
      return;
    }
    Helpers.showErrorSnackbar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              const SizedBox(height: 20),

              // Header
              _buildHeader(),

              const SizedBox(height: 32),

              // Form
              _buildForm(),

              const SizedBox(height: 32),

              // Sign up button
              _buildSignupButton(),

              const SizedBox(height: 16),

              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: AppTextStyles.labelSmall),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 16),

              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: () => _handleSocialSignup('google'),
                          theme: theme,
                          isLoading: authProvider.isGoogleLoading,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Facebook',
                          icon: Icons.facebook_rounded,
                          onPressed: () => _handleSocialSignup('facebook'),
                          theme: theme,
                          isLoading: authProvider.isFacebookLoading,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Login link
              _buildLoginLink(),

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
        Text(
          'Create Account',
          style: AppTextStyles.headlineLarge,
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          'Join WatchHub and discover luxury timepieces',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Name field
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),

            const SizedBox(height: 20),

            // Email field
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),

            const SizedBox(height: 20),

            // Phone field (optional)
            CustomTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhoneOptional,
            ),

            const SizedBox(height: 20),

            // Password field
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.iconSecondary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: Validators.validatePassword,
            ),

            const SizedBox(height: 20),

            // Confirm password field
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.iconSecondary,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildSignupButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingButton(
          onPressed: _handleSignup,
          isLoading: authProvider.isEmailLoading,
          text: 'Create Account',
        );
      },
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Sign In',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primaryGold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isLoading,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return OutlinedButton.icon(
          onPressed: authProvider.isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGold,
                  ),
                )
              : Icon(icon, size: 24),
          label: Text(
            isLoading ? '...' : label,
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: 0.5,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            backgroundColor: theme.cardColor.withOpacity(0.5),
            foregroundColor: theme.textTheme.bodyLarge?.color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        );
      },
    );
  }
}
