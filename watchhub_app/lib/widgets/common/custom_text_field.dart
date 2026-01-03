// =============================================================================
// FILE: custom_text_field.dart
// PURPOSE: Styled text field widget for WatchHub
// DESCRIPTION: Custom text field with premium styling, icons, and validation.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Custom styled text field
///
/// Features:
/// - Premium dark theme styling
/// - Prefix and suffix icon support
/// - Validation support
/// - Gold accent on focus
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color ??
            (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
        fontSize: 16,
      ),
      cursorColor: AppColors.primaryGold,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                color: isDark
                    ? AppColors.iconSecondary
                    : AppColors.iconSecondaryLight)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
                  isDark ? AppColors.inputBorder : AppColors.inputBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
                  isDark ? AppColors.inputBorder : AppColors.inputBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
                  (isDark ? AppColors.inputBorder : AppColors.inputBorderLight)
                      .withOpacity(0.5)),
        ),
        labelStyle: TextStyle(
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            fontSize: 14),
        hintStyle: TextStyle(
            color: isDark ? AppColors.textHint : AppColors.textHintLight,
            fontSize: 14),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),
    );
  }
}

/// Search text field with premium styling
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint = 'Search watches...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.inputBorder : AppColors.inputBorderLight),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color ??
              (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
          fontSize: 16,
        ),
        cursorColor: AppColors.primaryGold,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AppColors.textHint : AppColors.textHintLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color:
                isDark ? AppColors.iconSecondary : AppColors.iconSecondaryLight,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.iconSecondary
                        : AppColors.iconSecondaryLight,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
