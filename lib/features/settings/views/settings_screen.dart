import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/ui_constants.dart';
import 'sections/about_section.dart';
import 'sections/appearance_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMedium,
          vertical: UIConstants.spacingLarge,
        ),
        children: const [
          // Appearance Section
          AppearanceSection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // About Section
          AboutSection(),
        ],
      ),
    );
  }
}
