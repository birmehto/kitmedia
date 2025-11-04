import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/ui_constants.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/playback_controller.dart';
import '../controllers/privacy_controller.dart';
import '../controllers/storage_controller.dart';
import '../widgets/update_section.dart';
import 'sections/about_section.dart';
import 'sections/appearance_section.dart';
import 'sections/playback_section.dart';
import 'sections/privacy_section.dart';
import 'sections/storage_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Initialize controllers
    Get.lazyPut(() => PlaybackController());
    Get.lazyPut(() => StorageController());
    Get.lazyPut(() => PrivacyController());

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
        children: const [
          // Appearance Section
          AppearanceSection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // Playback Section
          PlaybackSection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // Storage Section
          StorageSection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // Privacy Section
          PrivacySection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // Update Section
          UpdateSection(),
          SizedBox(height: UIConstants.spacingXXLarge),

          // About Section
          AboutSection(),
        ],
      ),
    );
  }
}
