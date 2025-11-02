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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.error_rounded, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(
                'Video Player Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorMessage(error),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Symbols.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
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
    if (error.contains('channel-error') ||
        error.contains('PlatformException')) {
      return 'Video player is not properly configured on this device. This might be due to missing platform dependencies or emulator limitations.';
    }
    if (error.contains('Video file not found')) {
      return 'The video file could not be found. It may have been moved or deleted.';
    }
    if (error.contains('permission')) {
      return 'Permission denied. Please grant storage access to play videos.';
    }
    return 'An unexpected error occurred while trying to play the video. Please try again.';
  }
}
