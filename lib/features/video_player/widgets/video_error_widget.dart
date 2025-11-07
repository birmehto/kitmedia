import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class VideoErrorWidget extends StatelessWidget {
  const VideoErrorWidget({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.error.withValues(alpha: 0.2),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Symbols.error_rounded,
                    color: theme.colorScheme.error,
                    size: 64,
                    fill: 1,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Video Player Error',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error message card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.info_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getErrorMessage(error),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_shouldShowTroubleshootingTips(error)) ...[
                  const SizedBox(height: 24),
                  _buildTroubleshootingTips(context, error),
                ],

                const SizedBox(height: 40),

                // Action buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_shouldShowRetry(error))
                      _buildActionButton(
                        context,
                        icon: Symbols.refresh_rounded,
                        label: 'Retry',
                        onPressed: onRetry,
                        isPrimary: true,
                      ),
                    _buildActionButton(
                      context,
                      icon: Symbols.arrow_back_rounded,
                      label: 'Go Back',
                      onPressed: () => Get.back(),
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 2,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('Video file not found')) {
      return 'The video file could not be found. It may have been moved or deleted.';
    }
    if (error.contains('permission') || error.contains('Permission')) {
      return 'Permission denied. Please grant storage access to play videos.';
    }
    if (error.contains('Network') || error.contains('network')) {
      return 'Network error occurred while loading the video.';
    }
    if (error.contains('format') || error.contains('codec')) {
      return 'This video format is not supported on your device.';
    }
    if (error.contains('Playback error')) {
      return 'An error occurred during video playback. The file may be corrupted or incompatible.';
    }
    return error.isNotEmpty
        ? error
        : 'An unexpected error occurred while trying to play the video.';
  }

  bool _shouldShowTroubleshootingTips(String error) {
    return error.contains('format') ||
        error.contains('codec') ||
        error.contains('corrupted') ||
        error.contains('Playback error') ||
        error.contains('not found');
  }

  bool _shouldShowRetry(String error) {
    // Don't show retry for format errors as they won't work
    return !error.contains('format') &&
        !error.contains('codec') &&
        !error.contains('not supported');
  }

  Widget _buildTroubleshootingTips(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Symbols.lightbulb_rounded,
                  color: theme.colorScheme.onTertiary,
                  size: 24,
                  fill: 1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Troubleshooting Tips',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._getTroubleshootingTips(error).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTroubleshootingTips(String error) {
    if (error.contains('format') || error.contains('codec')) {
      return [
        'Try converting the video to MP4 format with H.264 codec',
        'Ensure the video file is not corrupted',
        'Check if the video plays in other media players',
        'Some older or proprietary formats may not be supported',
      ];
    }

    if (error.contains('not found')) {
      return [
        'Verify the video file still exists in the original location',
        'Check if the file was moved or renamed',
        'Ensure you have proper file access permissions',
        'Try refreshing the media library',
      ];
    }

    if (error.contains('Playback error')) {
      return [
        'The video file may be corrupted or incomplete',
        'Try playing the video in another media player',
        'Check available storage space on your device',
        'Restart the app and try again',
      ];
    }

    return [
      'Check if the video file exists and is accessible',
      'Ensure you have sufficient storage space',
      'Try restarting the app',
      'Verify file permissions are correct',
    ];
  }
}
