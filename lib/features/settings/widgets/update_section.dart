import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../controllers/update_controller.dart';

class UpdateSection extends StatelessWidget {
  const UpdateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateController>(
      init: UpdateController(),
      builder: (controller) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.system_update,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'app_updates'.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current version
              Text(
                controller.versionText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Update status
              Obx(
                () => Row(
                  children: [
                    if (controller.isCheckingUpdate)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (controller.hasUpdate)
                      Icon(
                        Symbols.new_releases,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    else
                      Icon(
                        Symbols.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.updateStatusText,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Obx(
                () => Row(
                  children: [
                    // Check for updates button
                    OutlinedButton.icon(
                      onPressed: controller.isCheckingUpdate
                          ? null
                          : controller.checkForUpdates,
                      icon: const Icon(Symbols.refresh),
                      label: Text('check_for_updates'.tr),
                    ),

                    if (controller.hasUpdate) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: controller.downloadUpdate,
                        icon: const Icon(Symbols.download),
                        label: Text('download'.tr),
                      ),
                    ],
                  ],
                ),
              ),

              // Release notes button (if update available)
              Obx(
                () => controller.hasUpdate && controller.latestRelease != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: controller.viewReleaseNotes,
                          icon: const Icon(Symbols.article),
                          label: Text('view_release_notes'.tr),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Release notes preview (if available)
              Obx(() {
                final release = controller.latestRelease;
                if (controller.hasUpdate &&
                    release != null &&
                    release.body.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'whats_new'.tr} ${release.tagName}:',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          release.body.length > 200
                              ? '${release.body.substring(0, 200)}...'
                              : release.body,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
