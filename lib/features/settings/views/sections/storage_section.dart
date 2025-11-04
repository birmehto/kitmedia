import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../controllers/storage_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Storage & Cache',
      icon: Symbols.storage_rounded,
      children: [
        // Cache Enabled
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.cached_rounded,
            title: 'Enable Cache',
            subtitle: 'Cache thumbnails and metadata for faster loading',
            trailing: Switch(
              value: controller.cacheEnabled,
              onChanged: controller.setCacheEnabled,
            ),
          ),
        ),

        // Current Cache Size
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.folder_rounded,
            title: 'Current Cache Size',
            subtitle: controller.currentCacheSize,
            trailing: TextButton(
              onPressed: controller.clearCache,
              child: const Text('Clear'),
            ),
          ),
        ),

        // Max Cache Size
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.data_usage_rounded,
            title: 'Maximum Cache Size',
            subtitle: controller.getCacheSizeString(controller.maxCacheSize),
            onTap: () => _showCacheSizeDialog(context, controller),
          ),
        ),

        // Auto Delete
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.auto_delete_rounded,
            title: 'Auto Delete Cache',
            subtitle: 'Automatically delete old cached files',
            trailing: Switch(
              value: controller.autoDeleteEnabled,
              onChanged: controller.setAutoDelete,
            ),
          ),
        ),

        // Auto Delete Days
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.schedule_rounded,
            title: 'Auto Delete After',
            subtitle: controller.getAutoDeleteString(controller.autoDeleteDays),
            onTap: controller.autoDeleteEnabled
                ? () => _showAutoDeleteDialog(context, controller)
                : null,
            enabled: controller.autoDeleteEnabled,
          ),
        ),

        // Available Storage
        GetBuilder<StorageController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.sd_storage_rounded,
            title: 'Available Storage',
            subtitle: controller.availableStorage,
            showTrailing: false,
          ),
        ),
      ],
    );
  }

  void _showCacheSizeDialog(
    BuildContext context,
    StorageController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Cache Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableCacheSizes.map((size) {
            return ListTile(
              title: Text(controller.getCacheSizeString(size)),
              leading: controller.maxCacheSize == size
                  ? const Icon(Symbols.check)
                  : null,
              onTap: () {
                controller.setMaxCacheSize(size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAutoDeleteDialog(
    BuildContext context,
    StorageController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Delete After'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableDeleteDays.map((days) {
            return ListTile(
              title: Text(controller.getAutoDeleteString(days)),
              leading: controller.autoDeleteDays == days
                  ? const Icon(Symbols.check)
                  : null,
              onTap: () {
                controller.setAutoDeleteDays(days);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
