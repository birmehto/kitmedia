import 'package:flutter/material.dart';

/// Reusable quality badge widget
class QualityBadge extends StatelessWidget {
  const QualityBadge({required this.fileSize, super.key});

  final int fileSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualityInfo = _getQualityInfo(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: qualityInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: qualityInfo.color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        qualityInfo.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: qualityInfo.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  ({String label, Color color}) _getQualityInfo(ThemeData theme) {
    if (fileSize > 500 * 1024 * 1024) {
      // > 500MB
      return (label: 'HD', color: theme.colorScheme.primary);
    } else if (fileSize > 100 * 1024 * 1024) {
      // > 100MB
      return (label: 'MD', color: theme.colorScheme.secondary);
    } else {
      return (label: 'SD', color: theme.colorScheme.tertiary);
    }
  }
}
