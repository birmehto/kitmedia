import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/utils/date_formatter.dart';

class VideoMetadataRow extends StatelessWidget {
  const VideoMetadataRow({
    required this.duration,
    required this.size,
    this.date,
    this.isCompact = false,
    super.key,
  });

  final String duration;
  final String size;
  final DateTime? date;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = isCompact ? 14.0 : 16.0;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: isCompact ? 12 : 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (duration.isNotEmpty)
          _MetadataChip(
            icon: Symbols.schedule_rounded,
            text: duration,
            iconSize: iconSize,
            textStyle: textStyle,
            theme: theme,
          ),
        _MetadataChip(
          icon: Symbols.storage_rounded,
          text: size,
          iconSize: iconSize,
          textStyle: textStyle,
          theme: theme,
        ),
        if (date != null && !isCompact)
          _MetadataChip(
            icon: Symbols.calendar_today_rounded,
            text: DateFormatter.formatRelativeDate(date!),
            iconSize: iconSize - 2,
            textStyle: textStyle?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            theme: theme,
          ),
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.text,
    required this.iconSize,
    required this.textStyle,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final double iconSize;
  final TextStyle? textStyle;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}
