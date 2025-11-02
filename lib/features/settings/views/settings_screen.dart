import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/core.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: Responsive.getPadding(context).copyWith(
          top: UIConstants.spacingLarge,
          bottom: UIConstants.spacingLarge,
        ),
        children: [
          // Language section with expressive card
          _buildExpressiveSection(
            context,
            'language'.tr,
            Symbols.language_rounded,
            [
              Obx(
                () => _buildExpressiveListTile(
                  context,
                  icon: Symbols.translate_rounded,
                  title: 'language'.tr,
                  subtitle: languageController.getLanguageName(
                    languageController.locale.languageCode,
                  ),
                  onTap: () => _showLanguageDialog(context, languageController),
                ),
              ),
            ],
          ),

          const SizedBox(height: UIConstants.spacingXXLarge),

          // Theme section with expressive card
          _buildExpressiveSection(
            context,
            'theme'.tr,
            Symbols.palette_rounded,
            [
              GetBuilder<ThemeController>(
                builder: (controller) => _buildExpressiveListTile(
                  context,
                  icon: Symbols.brightness_6_rounded,
                  title: 'theme'.tr,
                  subtitle: controller.themeModeString,
                  onTap: () => _showThemeDialog(context, controller),
                ),
              ),
              GetBuilder<ThemeController>(
                builder: (controller) => _buildExpressiveListTile(
                  context,
                  icon: Symbols.palette_rounded,
                  title: 'Dynamic Colors',
                  subtitle: controller.isDynamicColorEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  onTap: () => controller.toggleDynamicColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: UIConstants.spacingXXLarge),

          // About section with expressive card
          _buildExpressiveSection(context, 'About', Symbols.info_rounded, [
            _buildExpressiveListTile(
              context,
              icon: Symbols.app_settings_alt_rounded,
              title: 'Version',
              subtitle: AppConfig.appVersion,
              showTrailing: false,
            ),
            _buildExpressiveListTile(
              context,
              icon: Symbols.video_library_rounded,
              title: 'Supported Formats',
              subtitle: AppConfig.supportedVideoExtensions.join(', '),
              showTrailing: false,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildExpressiveSection(
    BuildContext context,
    String title,
    IconData sectionIcon,
    List<Widget> children,
  ) {
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
                    sectionIcon,
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

  Widget _buildExpressiveListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(UIConstants.spacingSmall),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onSecondaryContainer,
          size: UIConstants.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: showTrailing && onTap != null
          ? Icon(
              Symbols.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingXLarge,
        vertical: UIConstants.spacingXSmall,
      ),
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
          children: [
            _buildLanguageOption(
              context,
              controller,
              const Locale('en'),
              '🇺🇸 English',
            ),
            _buildLanguageOption(
              context,
              controller,
              const Locale('es'),
              '🇪🇸 Español',
            ),
            _buildLanguageOption(
              context,
              controller,
              const Locale('fr'),
              '🇫🇷 Français',
            ),
            _buildLanguageOption(
              context,
              controller,
              const Locale('de'),
              '🇩🇪 Deutsch',
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
