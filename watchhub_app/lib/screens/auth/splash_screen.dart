// =============================================================================
// FILE: splash_screen.dart
// PURPOSE: Animated splash screen for WatchHub
// DESCRIPTION: Premium animated splash with logo and loading indicator.
//              Checks auth state and navigates accordingly.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

/// Animated splash screen
///
/// This screen:
/// 1. Shows animated logo and tagline
/// 2. Checks authentication state
/// 3. Navigates to appropriate screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Navigate based on auth state
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.scaffoldBackground, AppColors.cardBackground],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.watch_rounded,
                    size: 64,
                    color: AppColors.scaffoldBackground,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App name
            Text(
                  'WatchHub',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Tagline
            Text(
                  'LUXURY TIMEPIECES',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryGold,
                    letterSpacing: 6,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),

            const SizedBox(height: 80),

            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold.withOpacity(0.7),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
