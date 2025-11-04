import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/ui_constants.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
    this.trailing,
    this.onTap,
    this.showTrailing = true,
    this.enabled = true,
    this.titleColor,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showTrailing;
  final bool enabled;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = onTap != null && enabled;

    return ListTile(
      enabled: enabled,
      leading: Container(
        padding: const EdgeInsets.all(UIConstants.spacingSmall),
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: enabled
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          size: UIConstants.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color:
              titleColor ??
              (enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      trailing:
          trailing ??
          (showTrailing && isInteractive
              ? Icon(
                  Symbols.chevron_right_rounded,
                  color: enabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                )
              : null),
      onTap: isInteractive ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingXLarge,
        vertical: UIConstants.spacingXSmall,
      ),
    );
  }
}
