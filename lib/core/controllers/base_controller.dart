import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/snackbar_service.dart';
import '../utils/logger.dart';

/// Base controller with common functionality to reduce code duplication
abstract class BaseController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Set error message
  void setError(String error, {BuildContext? context}) {
    _errorMessage.value = error;
    if (error.isNotEmpty) {
      appLog('Error in $runtimeType: $error');
      SnackbarService.showError(error, context: context);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  /// Show success message
  void showSuccess(String message, {BuildContext? context}) {
    SnackbarService.showSuccess(message, context: context);
  }

  /// Show info message
  void showInfo(String message, {BuildContext? context}) {
    SnackbarService.showInfo(message, context: context);
  }

  /// Show warning message
  void showWarning(String message, {BuildContext? context}) {
    SnackbarService.showWarning(message, context: context);
  }

  /// Execute an async operation with loading state and error handling
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? successMessage,
    bool showErrorSnackbar = true,
  }) async {
    try {
      setLoading(true);
      clearError();

      final result = await operation();

      if (successMessage != null) {
        showSuccess(successMessage);
      }

      return result;
    } catch (error) {
      final errorMsg = _getErrorMessage(error);
      if (showErrorSnackbar) {
        setError(errorMsg);
      } else {
        _errorMessage.value = errorMsg;
        appLog('Error in $runtimeType: $errorMsg');
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Execute an async operation without loading state
  Future<T?> executeSilently<T>(
    Future<T> Function() operation, {
    bool logErrors = true,
  }) async {
    try {
      clearError();
      return await operation();
    } catch (error) {
      final errorMsg = _getErrorMessage(error);
      _errorMessage.value = errorMsg;
      if (logErrors) {
        appLog('Silent error in $runtimeType: $errorMsg');
      }
      return null;
    }
  }

  /// Retry an operation with exponential backoff
  Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        if (attempts >= maxRetries) {
          setError(_getErrorMessage(error));
          return null;
        }

        appLog(
          'Retry attempt $attempts failed, retrying in ${delay.inSeconds}s',
        );
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }

    return null;
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
