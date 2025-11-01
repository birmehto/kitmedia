import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/services/cross_platform_video_player.dart';
import '../controllers/video_player_controller.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });
  final String videoPath;
  final String videoTitle;

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  double _initialPanPosition = 0.0;
  bool _isPanning = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>();

    return Obx(() {
      if (controller.isLoading) {
        return _buildLoadingWidget();
      }

      if (controller.hasError) {
        return _buildErrorWidget(controller);
      }

      if (!controller.isInitialized ||
          (CrossPlatformVideoPlayer.isMobile &&
              controller.chewieController == null)) {
        return _buildNotInitializedWidget();
      }

      return _buildVideoPlayerWithGestures(controller);
    });
  }

  Widget _buildLoadingWidget() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Material 3 loading indicator with custom styling
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading video...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare your content',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(VideoPlayerController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.errorContainer.withValues(alpha: 0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Material 3 error icon with container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Symbols.error_outline_rounded,
                color: colorScheme.onErrorContainer,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load video',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            // Material 3 filled tonal button
            FilledButton.tonalIcon(
              onPressed: () => controller.retryInitialization(widget.videoPath),
              icon: const Icon(Symbols.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotInitializedWidget() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Material 3 icon with surface container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Symbols.video_library_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preparing video player',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Setting up your viewing experience',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerWithGestures(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () {
        controller.toggleControls();
        controller.hideAllSliders();
      },
      onDoubleTap: controller.togglePlayPause,
      onPanStart: (details) {
        _initialPanPosition = details.globalPosition.dx;
        _isPanning = true;
      },
      onPanUpdate: (details) {
        if (!_isPanning) return;

        final screenWidth = MediaQuery.of(context).size.width;
        final deltaX = details.globalPosition.dx - _initialPanPosition;
        final deltaY = details.delta.dy;

        // Horizontal pan for seeking
        if (deltaX.abs() > deltaY.abs()) {
          final seekDelta = (deltaX / screenWidth) * 30; // 30 seconds max
          controller.seekByGesture(seekDelta);
        }
        // Vertical pan for volume/brightness
        else {
          final isLeftSide = details.globalPosition.dx < screenWidth / 2;
          final delta = -deltaY / 200; // Normalize delta

          if (isLeftSide) {
            // Left side controls brightness
            controller.adjustBrightnessByGesture(delta);
          } else {
            // Right side controls volume
            controller.adjustVolumeByGesture(delta);
          }
        }
      },
      onPanEnd: (details) {
        _isPanning = false;
      },
      child: Stack(
        children: [
          _buildVideoWidget(controller),
          // Gesture feedback overlays
          _buildGestureFeedback(controller),
        ],
      ),
    );
  }

  Widget _buildVideoWidget(VideoPlayerController controller) {
    // Mobile video player using Chewie
    if (CrossPlatformVideoPlayer.isMobile &&
        controller.chewieController != null) {
      return AspectRatio(
        aspectRatio: controller.videoPlayerController!.value.aspectRatio,
        child: Chewie(controller: controller.chewieController!),
      );
    }

    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video player not available',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGestureFeedback(VideoPlayerController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned.fill(
      child: Row(
        children: [
          // Left side - brightness indicator
          Expanded(
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.showBrightnessSlider ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: controller.showBrightnessSlider
                    ? Container(
                        margin: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Material 3 surface container for feedback
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.brightness_6_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(controller.brightness * 100).round()}%',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Brightness',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Right side - volume indicator
          Expanded(
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.showVolumeSlider ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: controller.showVolumeSlider
                    ? Container(
                        margin: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Material 3 surface container for feedback
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.volume > 0.5
                                        ? Symbols.volume_up_rounded
                                        : controller.volume > 0
                                        ? Symbols.volume_down_rounded
                                        : Symbols.volume_off_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(controller.volume * 100).round()}%',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Volume',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
