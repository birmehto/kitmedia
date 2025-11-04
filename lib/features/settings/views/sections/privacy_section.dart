import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../controllers/privacy_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class PrivacySection extends StatelessWidget {
  const PrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Privacy & Security',
      icon: Symbols.privacy_tip_rounded,
      children: [
        // Analytics
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.analytics_rounded,
            title: 'Analytics',
            subtitle: 'Help improve the app by sharing usage data',
            trailing: Switch(
              value: controller.analyticsEnabled,
              onChanged: controller.setAnalytics,
            ),
          ),
        ),

        // Crash Reporting
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.bug_report_rounded,
            title: 'Crash Reporting',
            subtitle: 'Automatically send crash reports to help fix issues',
            trailing: Switch(
              value: controller.crashReportingEnabled,
              onChanged: controller.setCrashReporting,
            ),
          ),
        ),

        // Usage Statistics
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.bar_chart_rounded,
            title: 'Usage Statistics',
            subtitle: 'Collect anonymous usage statistics',
            trailing: Switch(
              value: controller.usageStatsEnabled,
              onChanged: controller.setUsageStats,
            ),
          ),
        ),

        // Location Access
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.location_on_rounded,
            title: 'Location Access',
            subtitle: 'Allow access to device location for media organization',
            trailing: Switch(
              value: controller.locationAccessEnabled,
              onChanged: controller.setLocationAccess,
            ),
          ),
        ),

        // Biometric Lock
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: 'Require fingerprint or face unlock to open app',
            trailing: Switch(
              value: controller.biometricLockEnabled,
              onChanged: controller.setBiometricLock,
            ),
          ),
        ),

        // Incognito Mode
        GetBuilder<PrivacyController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.visibility_off_rounded,
            title: 'Incognito Mode',
            subtitle: 'Don\'t save viewing history or recent files',
            trailing: Switch(
              value: controller.incognitoModeEnabled,
              onChanged: controller.setIncognitoMode,
            ),
          ),
        ),

        // Reset All Data
        SettingsTile(
          icon: Symbols.delete_forever_rounded,
          title: 'Reset All Data',
          subtitle: 'Clear all app data and reset to defaults',
          onTap: () => Get.find<PrivacyController>().resetAllData(),
          titleColor: Get.theme.colorScheme.error,
        ),
      ],
    );
  }
}
