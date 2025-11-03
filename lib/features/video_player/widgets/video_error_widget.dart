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
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Symbols.error_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Video Player Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  _getErrorMessage(error),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_shouldShowTroubleshootingTips(error)) ...[
                const SizedBox(height: 24),
                _buildTroubleshootingTips(error),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_shouldShowRetry(error)) ...[
                    _buildActionButton(
                      icon: Symbols.refresh_rounded,
                      label: 'Retry',
                      onPressed: onRetry,
                      isPrimary: true,
                    ),
                    const SizedBox(width: 16),
                  ],
                  _buildActionButton(
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1.5,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.black : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildTroubleshootingTips(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Symbols.lightbulb_rounded, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'Troubleshooting Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._getTroubleshootingTips(error).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
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
