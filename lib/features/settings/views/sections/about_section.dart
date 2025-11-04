import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/device_utils.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final version = packageInfo?.version ?? AppConfig.appVersion;
        final buildNumber =
            packageInfo?.buildNumber ?? AppConfig.buildNumber.toString();

        return SettingsSection(
          title: 'About',
          icon: Symbols.info_rounded,
          children: [
            // App Version
            SettingsTile(
              icon: Symbols.app_settings_alt_rounded,
              title: 'Version',
              subtitle: version,
              showTrailing: false,
            ),

            // Supported Formats
            SettingsTile(
              icon: Symbols.video_library_rounded,
              title: 'Supported Formats',
              subtitle: AppConfig.supportedVideoExtensions.join(', '),
              showTrailing: false,
            ),

            // Build Number
            SettingsTile(
              icon: Symbols.build_rounded,
              title: 'Build Number',
              subtitle: buildNumber,
              showTrailing: false,
            ),

            // Device Info
            SettingsTile(
              icon: Symbols.smartphone_rounded,
              title: 'Device Information',
              subtitle: 'View device details',
              onTap: () => _showDeviceInfo(context),
            ),

            // Developer
            SettingsTile(
              icon: Symbols.person_rounded,
              title: 'Developer',
              subtitle: 'KitMedia Team',
              onTap: () => _showDeveloperInfo(context),
            ),

            // License
            SettingsTile(
              icon: Symbols.gavel_rounded,
              title: 'License',
              subtitle: 'Open Source License',
              onTap: () => _showLicenseDialog(context),
            ),

            // Privacy Policy
            SettingsTile(
              icon: Symbols.policy_rounded,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              onTap: () => _showPrivacyPolicy(context),
            ),

            // Terms of Service
            SettingsTile(
              icon: Symbols.description_rounded,
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              onTap: () => _showTermsOfService(context),
            ),

            // Rate App
            SettingsTile(
              icon: Symbols.star_rounded,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: () => _rateApp(),
            ),

            // Share App
            SettingsTile(
              icon: Symbols.share_rounded,
              title: 'Share App',
              subtitle: 'Share KitMedia with friends',
              onTap: () => _shareApp(),
            ),
          ],
        );
      },
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KitMedia Team'),
            SizedBox(height: 8),
            Text('A modern media player built with Flutter'),
            SizedBox(height: 16),
            Text('Contact: support@kitmedia.app'),
            Text('Website: www.kitmedia.app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLicenseDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;

    if (!context.mounted) return;

    showLicensePage(
      context: context,
      applicationName: 'KitMedia',
      applicationVersion: version,
      applicationLegalese: '© 2024 KitMedia Team',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the privacy policy. '
            'In a real app, you would load the actual privacy policy content here.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the terms of service. '
            'In a real app, you would load the actual terms content here.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeviceInfo(BuildContext context) async {
    final deviceSummary = await DeviceUtils.getDeviceSummary();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Platform',
                deviceSummary['device']['platform'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'Model',
                deviceSummary['device']['model'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'Manufacturer',
                deviceSummary['device']['manufacturer'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'OS Version',
                deviceSummary['device']['androidVersion'] ??
                    deviceSummary['device']['systemVersion'] ??
                    'Unknown',
              ),
              _buildInfoRow(
                'App Version',
                deviceSummary['app']['version'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'Build Number',
                deviceSummary['app']['buildNumber'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'Battery Level',
                '${deviceSummary['battery']['level'] ?? 'Unknown'}%',
              ),
              _buildInfoRow(
                'Is Tablet',
                deviceSummary['isTablet'] ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'High Refresh Rate',
                deviceSummary['supportsHighRefreshRate']
                    ? 'Supported'
                    : 'Not Supported',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.kitmedia.player';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open app store',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _shareApp() async {
    const text =
        'Check out KitMedia - A powerful video player for Android!\n'
        'Download: https://play.google.com/store/apps/details?id=com.kitmedia.player';
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
