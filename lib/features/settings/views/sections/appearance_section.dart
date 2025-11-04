import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/ui_constants.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/theme_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();

    return SettingsSection(
      title: 'appearance'.tr,
      icon: Symbols.palette_rounded,
      children: [
        // Language Setting
        Obx(
          () => SettingsTile(
            icon: Symbols.translate_rounded,
            title: 'language'.tr,
            subtitle: languageController.getLanguageName(
              languageController.locale.languageCode,
            ),
            onTap: () => _showLanguageDialog(context, languageController),
          ),
        ),

        // Theme Setting
        GetBuilder<ThemeController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.brightness_6_rounded,
            title: 'theme'.tr,
            subtitle: controller.themeModeString,
            onTap: () => _showThemeDialog(context, controller),
          ),
        ),

        // Dynamic Colors
        GetBuilder<ThemeController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.palette_rounded,
            title: 'Dynamic Colors',
            subtitle: controller.isDynamicColorEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: controller.isDynamicColorEnabled,
              onChanged: (value) => controller.toggleDynamicColor(),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageController controller,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingSmall),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: UIConstants.borderRadiusMediumAll,
              ),
              child: Icon(
                Symbols.language_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: UIConstants.iconSizeMedium,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Text(
              'language'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.supportedLocales
              .map(
                (locale) => _buildLanguageOption(
                  context,
                  controller,
                  locale,
                  controller.getLanguageDisplayName(locale.languageCode),
                ),
              )
              .toList(),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageController controller,
    Locale locale,
    String title,
  ) {
    return Obx(() {
      final isSelected = controller.locale == locale;
      return ListTile(
        title: Text(title),
        leading: isSelected ? const Icon(Symbols.check) : null,
        onTap: () {
          controller.setLanguage(locale);
          Navigator.pop(context);
        },
      );
    });
  }

  void _showThemeDialog(BuildContext context, ThemeController controller) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingSmall),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: UIConstants.borderRadiusMediumAll,
              ),
              child: Icon(
                Symbols.palette_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: UIConstants.iconSizeMedium,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Text(
              'theme'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              controller,
              ThemeMode.light,
              'light_theme'.tr,
              Symbols.light_mode_rounded,
            ),
            _buildThemeOption(
              context,
              controller,
              ThemeMode.dark,
              'dark_theme'.tr,
              Symbols.dark_mode_rounded,
            ),
            _buildThemeOption(
              context,
              controller,
              ThemeMode.system,
              'system_theme'.tr,
              Symbols.brightness_auto_rounded,
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeController controller,
    ThemeMode themeMode,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Obx(() {
      final isSelected = controller.themeMode == themeMode;
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(UIConstants.spacingSmall),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            size: UIConstants.iconSizeMedium,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Symbols.check_circle_rounded,
                color: theme.colorScheme.primary,
              )
            : null,
        onTap: () {
          controller.setTheme(themeMode);
          Navigator.pop(context);
        },
      );
    });
  }
}
