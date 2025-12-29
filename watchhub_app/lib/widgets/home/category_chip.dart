// =============================================================================
// FILE: category_chip.dart
// PURPOSE: Category chip widget for WatchHub
// DESCRIPTION: Tappable chip for category filtering.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandChip extends StatelessWidget {
  final String brand;
  final bool isSelected;
  final VoidCallback? onTap;

  const BrandChip({
    super.key,
    required this.brand,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.goldGradient : null,
          color: isSelected ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        child: Text(
          brand,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected
                ? AppColors.scaffoldBackground
                : AppColors.primaryGold,
          ),
        ),
      ),
    );
  }
}
