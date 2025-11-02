import 'package:flutter/material.dart';

import '../services/snackbar_service.dart';

class ErrorHandler {
  /// Show error snackbar using centralized service
  static void showErrorSnackBar(BuildContext context, String message) {
    SnackbarService.showError(message, context: context);
  }

  /// Show success snackbar using centralized service
  static void showSuccessSnackBar(BuildContext context, String message) {
    SnackbarService.showSuccess(message, context: context);
  }

  /// Show info snackbar using centralized service
  static void showInfoSnackBar(BuildContext context, String message) {
    SnackbarService.showInfo(message, context: context);
  }

  /// Show warning snackbar using centralized service
  static void showWarningSnackBar(BuildContext context, String message) {
    SnackbarService.showWarning(message, context: context);
  }

  /// Extract clean error message from various error types
  static String getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Handle and display error with optional retry action
  static void handleError(
    Object error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? getErrorMessage(error);
    SnackbarService.showError(
      message,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  /// Handle async operation with error handling
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (showError) {
        final message = errorMessage ?? getErrorMessage(error);
        SnackbarService.showError(message);
      }
      onError?.call();
      return null;
    }
  }
}
