// =============================================================================
// FILE: helpers.dart
// PURPOSE: Utility helper functions for WatchHub
// DESCRIPTION: Common helper methods for formatting, conversions, and other
//              utility operations used throughout the application.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility helper functions for WatchHub
///
/// This class provides static methods for common operations like
/// formatting currency, dates, and other transformations.
class Helpers {
  // Private constructor to prevent instantiation
  Helpers._();

  // ===========================================================================
  // CURRENCY FORMATTING
  // ===========================================================================

  /// Formats a price as currency (USD)
  ///
  /// Example: 25000.00 → "$25,000.00"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats a price without decimal places
  ///
  /// Example: 25000.00 → "$25,000"
  static String formatCurrencyCompact(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formats a large number in compact form
  ///
  /// Example: 1500000 → "$1.5M"
  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return formatCurrency(amount);
  }

  // ===========================================================================
  // DATE FORMATTING
  // ===========================================================================

  /// Formats a DateTime to a readable date
  ///
  /// Example: "December 29, 2025"
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Formats a DateTime to a short date
  ///
  /// Example: "Dec 29, 2025"
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats a DateTime to date and time
  ///
  /// Example: "Dec 29, 2025 at 2:30 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  /// Formats a DateTime relative to now
  ///
  /// Examples: "Just now", "5 minutes ago", "2 hours ago", "Yesterday"
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return formatDateShort(date);
    }
  }

  // ===========================================================================
  // STRING FORMATTING
  // ===========================================================================

  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalizes the first letter of each word
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncates a string to a maximum length with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Removes extra whitespace from a string
  static String cleanWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ===========================================================================
  // NUMBER FORMATTING
  // ===========================================================================

  /// Formats a number with thousands separator
  ///
  /// Example: 1234567 → "1,234,567"
  static String formatNumber(num number) {
    return NumberFormat('#,###').format(number);
  }

  /// Pads a number with leading zeros
  ///
  /// Example: padNumber(7, 2) → "07"
  static String padNumber(int number, int width) {
    return number.toString().padLeft(width, '0');
  }

  // ===========================================================================
  // ORDER STATUS HELPERS
  // ===========================================================================

  /// Gets the color for an order status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Gets an icon for an order status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // ===========================================================================
  // RATING HELPERS
  // ===========================================================================

  /// Rounds a rating to nearest 0.5
  static double roundRating(double rating) {
    return (rating * 2).round() / 2;
  }

  /// Gets a text description for a rating
  static String getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Fair';
    return 'Poor';
  }

  // ===========================================================================
  // SNACKBAR HELPERS
  // ===========================================================================

  /// Shows a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message,
      {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: action,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Shows an info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===========================================================================
  // DIALOG HELPERS
  // ===========================================================================

  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ===========================================================================
  // IMAGE HELPERS
  // ===========================================================================

  /// Returns a placeholder asset path for a watch brand
  static String getBrandPlaceholder(String brand) {
    // Returns a generic placeholder path - actual images would be generated
    return 'assets/images/placeholder_watch.png';
  }

  /// Generates initials from a name
  ///
  /// Example: "John Doe" → "JD"
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
