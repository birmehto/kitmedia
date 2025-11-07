import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        final version = packageInfo?.version;

        return SettingsSection(
          title: 'About',
          icon: Symbols.info_rounded,
          children: [
            // App Version
            SettingsTile(
              icon: Symbols.app_settings_alt_rounded,
              title: 'Version',
              subtitle: version != null ? 'v$version' : 'Unknown',
              showTrailing: false,
            ),
            // License
            SettingsTile(
              icon: Symbols.gavel_rounded,
              title: 'License',
              subtitle: 'Open Source License',
              onTap: () => _showLicenseDialog(context),
            ),
          ],
        );
      },
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
      applicationLegalese: '© 2025 KitMedia Team',
    );
  }
}
