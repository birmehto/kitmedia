import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/ui_constants.dart';

/// Centralized service for showing consistent snackbars throughout the app
class SnackbarService {
  static void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final scaffoldMessenger = context != null
        ? ScaffoldMessenger.of(context)
        : ScaffoldMessenger.of(Get.context!);

    final theme = context != null ? Theme.of(context) : Get.theme;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: UIConstants.iconSizeMedium,
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(UIConstants.spacingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.error,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  static void showSuccess(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final scaffoldMessenger = context != null
        ? ScaffoldMessenger.of(context)
        : ScaffoldMessenger.of(Get.context!);

    final theme = context != null ? Theme.of(context) : Get.theme;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.onPrimaryContainer,
              size: UIConstants.iconSizeMedium,
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(UIConstants.spacingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        duration: const Duration(seconds: 3),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.primary,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  static void showInfo(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final scaffoldMessenger = context != null
        ? ScaffoldMessenger.of(context)
        : ScaffoldMessenger.of(Get.context!);

    final theme = context != null ? Theme.of(context) : Get.theme;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: UIConstants.iconSizeMedium,
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(UIConstants.spacingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        duration: const Duration(seconds: 3),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.primary,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  static void showWarning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final scaffoldMessenger = context != null
        ? ScaffoldMessenger.of(context)
        : ScaffoldMessenger.of(Get.context!);

    final theme = context != null ? Theme.of(context) : Get.theme;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme.colorScheme.onTertiaryContainer,
              size: UIConstants.iconSizeMedium,
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(UIConstants.spacingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.tertiary,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  static void showCustom({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final scaffoldMessenger = context != null
        ? ScaffoldMessenger.of(context)
        : ScaffoldMessenger.of(Get.context!);

    final theme = context != null ? Theme.of(context) : Get.theme;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: UIConstants.iconSizeMedium,
              ),
              const SizedBox(width: UIConstants.spacingMedium),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(UIConstants.spacingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        duration: duration ?? const Duration(seconds: 3),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: iconColor ?? theme.colorScheme.primary,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  /// Convenience method to show snackbar with context
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    switch (type) {
      case SnackbarType.success:
        showSuccess(
          message,
          context: context,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case SnackbarType.error:
        showError(
          message,
          context: context,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case SnackbarType.warning:
        showWarning(
          message,
          context: context,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case SnackbarType.info:
        showInfo(
          message,
          context: context,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
    }
  }
}

enum SnackbarType { success, error, warning, info }
