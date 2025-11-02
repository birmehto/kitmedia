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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.error_rounded, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Video Player Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorMessage(error),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (_shouldShowTroubleshootingTips(error)) ...[
                const SizedBox(height: 16),
                _buildTroubleshootingTips(error),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_shouldShowRetry(error))
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Symbols.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (_shouldShowRetry(error)) const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Symbols.arrow_back_rounded),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String error) {
    // Media Kit specific errors
    if (error.contains('Failed to open') || error.contains('Could not open')) {
      return error; // Use the detailed message from controller
    }
    if (error.contains('Cannot play this video format') ||
        error.contains('Source error') ||
        error.contains('ExoPlaybackException')) {
      return error; // Use the detailed message from controller
    }
    if (error.contains('Video file not found')) {
      return 'The video file could not be found. It may have been moved or deleted.';
    }
    if (error.contains('permission')) {
      return 'Permission denied. Please grant storage access to play videos.';
    }
    if (error.contains('Network') || error.contains('network')) {
      return 'Network error occurred while loading the video.';
    }
    if (error.contains('Unsupported video format')) {
      return error; // Use the detailed message from controller
    }
    if (error.contains('format') || error.contains('codec')) {
      return 'This video format is not supported on your device.';
    }
    return error.isNotEmpty
        ? error
        : 'An unexpected error occurred while trying to play the video.';
  }

  bool _shouldShowTroubleshootingTips(String error) {
    return error.contains('format') ||
        error.contains('codec') ||
        error.contains('corrupted') ||
        error.contains('Source error') ||
        error.contains('ExoPlaybackException') ||
        error.contains('Failed to open') ||
        error.contains('Could not open');
  }

  bool _shouldShowRetry(String error) {
    // Don't show retry for format errors as they won't work
    return !error.contains('Unsupported video format') &&
        !error.contains('format') &&
        !error.contains('codec');
  }

  Widget _buildTroubleshootingTips(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Symbols.lightbulb_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Troubleshooting Tips:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._getTroubleshootingTips(error).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
    if (error.contains('webm') || error.contains('.webm')) {
      return [
        'Media Kit has better WebM support than the previous player',
        'If still having issues, try converting to MP4 format',
        'Check if the video plays in other media players on your device',
      ];
    }

    if (error.contains('Failed to open') || error.contains('Could not open')) {
      return [
        'The video file may be corrupted or use an unsupported codec',
        'Try playing the video in another media player to verify it works',
        'Consider converting to MP4 with H.264 codec for best compatibility',
      ];
    }

    if (error.contains('format') || error.contains('codec')) {
      return [
        'Try converting the video to MP4 format',
        'Ensure the video uses H.264 codec for best compatibility',
        'Check if the video file is corrupted',
      ];
    }

    if (error.contains('Source error') || error.contains('corrupted')) {
      return [
        'The video file may be corrupted or incomplete',
        'Try re-downloading or re-copying the video file',
        'Check if the video plays in other apps',
      ];
    }

    return [
      'Check if the video file exists and is accessible',
      'Ensure you have sufficient storage space',
      'Try restarting the app',
    ];
  }
}
