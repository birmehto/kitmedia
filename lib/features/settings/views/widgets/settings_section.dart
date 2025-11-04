import 'package:flutter/material.dart';

import '../../../../core/theme/ui_constants.dart';
import '../../../../core/widgets/common/ui_factory.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UIFactory.buildCard(
      theme: theme,
      elevation: UIConstants.elevationLow,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.spacingXLarge,
              UIConstants.spacingXLarge,
              UIConstants.spacingXLarge,
              UIConstants.spacingSmall,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: UIConstants.borderRadiusMediumAll,
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: UIConstants.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Section content
          ...children,

          const SizedBox(height: UIConstants.spacingSmall),
        ],
      ),
    );
  }
}
