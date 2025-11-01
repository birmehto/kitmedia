import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Reusable selection dialog for options like theme, language, etc.
class SelectionDialog<T> extends StatelessWidget {
  const SelectionDialog({
    required this.title,
    required this.icon,
    required this.options,
    required this.currentValue,
    required this.onSelected,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<SelectionOption<T>> options;
  final T currentValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((option) => _buildOption(context, option))
            .toList(),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, SelectionOption<T> option) {
    final theme = Theme.of(context);
    final isSelected = currentValue == option.value;

    return ListTile(
      leading:
          option.leading ??
          (isSelected
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.check,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                )
              : null),
      title: Text(
        option.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: option.subtitle != null
          ? Text(
              option.subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(Symbols.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        onSelected(option.value);
        Navigator.pop(context);
      },
    );
  }
}

class SelectionOption<T> {
  const SelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? leading;
}
