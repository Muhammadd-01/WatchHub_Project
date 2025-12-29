// =============================================================================
// FILE: validators.dart
// PURPOSE: Form validation utilities for WatchHub
// DESCRIPTION: Provides reusable validation functions for email, password,
//              phone numbers, and other form inputs throughout the app.
// =============================================================================

/// Form validation utilities for WatchHub
///
/// This class provides static methods for validating various form inputs.
/// All methods return null if valid, or an error message string if invalid.
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // ===========================================================================
  // EMAIL VALIDATION
  // ===========================================================================

  /// Validates an email address
  ///
  /// Returns null if valid, error message if invalid.
  ///
  /// Example:
  /// ```dart
  /// TextFormField(
  ///   validator: (value) => Validators.validateEmail(value),
  /// )
  /// ```
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Remove whitespace
    value = value.trim();

    // Check for valid email format using regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ===========================================================================
  // PASSWORD VALIDATION
  // ===========================================================================

  /// Validates a password
  ///
  /// Requirements:
  /// - At least 6 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Simple password validation (minimum length only)
  ///
  /// Use this for login where we don't want to reveal password requirements.
  static String? validatePasswordSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates password confirmation matches
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ===========================================================================
  // NAME VALIDATION
  // ===========================================================================

  /// Validates a name (first name, last name, or full name)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ===========================================================================
  // PHONE VALIDATION
  // ===========================================================================

  /// Validates a phone number
  ///
  /// Accepts various formats:
  /// - +1234567890
  /// - 123-456-7890
  /// - (123) 456-7890
  /// - 1234567890
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Optional phone validation (allows empty)
  static String? validatePhoneOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional, so empty is valid
    }

    return validatePhone(value);
  }

  // ===========================================================================
  // GENERAL VALIDATION
  // ===========================================================================

  /// Validates that a field is not empty
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'This field',
  }) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  // ===========================================================================
  // NUMERIC VALIDATION
  // ===========================================================================

  /// Validates that a value is a valid number
  static String? validateNumber(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validates that a value is a valid positive number
  static String? validatePositiveNumber(
    String? value, {
    String fieldName = 'This field',
  }) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  // ===========================================================================
  // REVIEW/FEEDBACK VALIDATION
  // ===========================================================================

  /// Validates a review comment
  static String? validateReview(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write a review';
    }

    if (value.trim().length < 10) {
      return 'Review must be at least 10 characters';
    }

    if (value.length > 500) {
      return 'Review must be less than 500 characters';
    }

    return null;
  }

  /// Validates a feedback message
  static String? validateFeedback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your feedback';
    }

    if (value.trim().length < 20) {
      return 'Feedback must be at least 20 characters';
    }

    if (value.length > 1000) {
      return 'Feedback must be less than 1000 characters';
    }

    return null;
  }

  // ===========================================================================
  // RATING VALIDATION
  // ===========================================================================

  /// Validates a rating value
  static String? validateRating(double? value) {
    if (value == null || value == 0) {
      return 'Please select a rating';
    }

    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }

    return null;
  }
}
