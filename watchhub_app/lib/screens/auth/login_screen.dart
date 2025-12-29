// =============================================================================
// FILE: login_screen.dart
// PURPOSE: Login screen for WatchHub
// DESCRIPTION: Premium login UI with email/password authentication.
//              Uses Firebase Auth through AuthProvider.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../core/utils/helpers.dart';

/// Login screen with premium design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      } else if (mounted && authProvider.errorMessage != null) {
        _handleError(authProvider.errorMessage!);
      }
    } catch (e) {
      if (mounted) _handleError(e.toString());
    }
  }

  void _handleError(String message) {
    if (message.contains('user-not-found') ||
        message.contains('no user record')) {
      Helpers.showErrorSnackbar(
        context,
        'Account not found. Please sign up.',
        action: SnackBarAction(
          label: 'Sign Up',
          textColor: AppColors.primaryGold,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        ),
      );
    } else if (message.contains('wrong-password')) {
      Helpers.showErrorSnackbar(context, 'Incorrect password. Try again.');
    } else {
      Helpers.showErrorSnackbar(context, message);
    }
  }

  // --- Helper Methods (Moved up to prevent scope issues) ---

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
          ),
          child: const Icon(
            Icons.watch_rounded,
            size: 40,
            color: AppColors.scaffoldBackground,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fadeIn(),

        const SizedBox(height: 24),

        // Title
        Text(
          'Welcome Back',
          style: AppTextStyles.headlineLarge,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in to continue to WatchHub',
          style: AppTextStyles.bodyMedium,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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

            // Password field
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
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
              validator: Validators.validatePasswordSimple,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
        },
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primaryGold,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingButton(
          onPressed: _handleLogin,
          isLoading: authProvider.isLoading,
          text: 'Sign In',
        );
      },
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don\'t have an account? ', style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.signup);
          },
          child: Text(
            'Sign Up',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primaryGold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo and welcome text
              _buildHeader(),

              const SizedBox(height: 48),

              // Login form
              _buildLoginForm(),

              const SizedBox(height: 24),

              // Forgot password
              _buildForgotPassword(),

              const SizedBox(height: 32),

              // Login button
              _buildLoginButton(),

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
              ).animate().fadeIn(delay: 650.ms),

              const SizedBox(height: 16),

              // Google Sign In Button
              OutlinedButton.icon(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.signInWithGoogle();
                  if (success && mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
                  }
                },
                icon: Image.asset('assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 24)),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.dividerColor),
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 24),

              // Sign up link
              _buildSignUpLink(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
