// =============================================================================
// FILE: loading_button.dart
// PURPOSE: Loading-state button widget for WatchHub
// DESCRIPTION: Premium button with loading indicator support.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Premium loading button
///
/// Features:
/// - Gold gradient background
/// - Loading state with spinner
/// - Disabled state styling
class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final double? width;
  final double height;
  final IconData? icon;
  final bool outlined;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return _buildOutlinedButton();
    }
    return _buildFilledButton();
  }

  Widget _buildFilledButton() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isLoading || onPressed == null
            ? null
            : AppColors.goldGradient,
        color: isLoading || onPressed == null ? AppColors.cardBackground : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLoading || onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: AppColors.scaffoldBackground,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(text, style: AppTextStyles.goldButton),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoading || onPressed == null
              ? AppColors.textTertiary
              : AppColors.primaryGold,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Small icon button with premium styling
class GoldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool filled;

  const GoldIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled ? AppColors.goldGradient : null,
        border: filled
            ? null
            : Border.all(color: AppColors.primaryGold, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(
              icon,
              color: filled
                  ? AppColors.scaffoldBackground
                  : AppColors.primaryGold,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
