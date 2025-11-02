import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/services/cross_platform_video_player.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../controllers/video_player_controller.dart';
import 'video_error_widget.dart';

class CustomVideoPlayer extends StatelessWidget {
  const CustomVideoPlayer({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });

  final String videoPath;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    return GetX<VideoPlayerController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _buildLoadingWidget(context);
        }

        if (controller.hasError) {
          return _buildErrorWidget(context, controller);
        }

        if (!controller.isInitialized ||
            (CrossPlatformVideoPlayer.isMobile &&
                controller.chewieController == null)) {
          return _buildNotInitializedWidget(context);
        }

        return _VideoPlayerGestureHandler(
          controller: controller,
          child: _buildVideoWidget(controller),
        );
      },
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
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
            const SizedBox(width: 56, height: 56, child: LoadingIndicator()),
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

  Widget _buildErrorWidget(
    BuildContext context,
    VideoPlayerController controller,
  ) {
    return VideoErrorWidget(
      error: controller.errorMessage,
      onRetry: () => controller.retryInitialization(videoPath),
    );
  }

  Widget _buildNotInitializedWidget(BuildContext context) {
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

  Widget _buildVideoWidget(VideoPlayerController controller) {
    // Mobile video player using Chewie
    if (CrossPlatformVideoPlayer.isMobile &&
        controller.chewieController != null &&
        controller.videoPlayerController != null &&
        controller.videoPlayerController!.value.isInitialized) {
      final aspectRatio = controller.videoPlayerController!.value.aspectRatio;
      final validAspectRatio = aspectRatio > 0 ? aspectRatio : 16 / 9;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: validAspectRatio,
            child: Chewie(controller: controller.chewieController!),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Center(
        child: Text(
          'Video player not available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _VideoPlayerGestureHandler extends StatefulWidget {
  const _VideoPlayerGestureHandler({
    required this.controller,
    required this.child,
  });

  final VideoPlayerController controller;
  final Widget child;

  @override
  State<_VideoPlayerGestureHandler> createState() =>
      _VideoPlayerGestureHandlerState();
}

class _VideoPlayerGestureHandlerState
    extends State<_VideoPlayerGestureHandler> {
  double _initialPanPosition = 0.0;
  bool _isPanning = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.toggleControls();
        widget.controller.hideAllSliders();
      },
      onDoubleTap: widget.controller.togglePlayPause,
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
          widget.controller.seekByGesture(seekDelta);
        }
        // Vertical pan for volume/brightness
        else {
          final isLeftSide = details.globalPosition.dx < screenWidth / 2;
          final delta = -deltaY / 200; // Normalize delta

          if (isLeftSide) {
            // Left side controls brightness
            widget.controller.adjustBrightnessByGesture(delta);
          } else {
            // Right side controls volume
            widget.controller.adjustVolumeByGesture(delta);
          }

          // Provide haptic feedback for better UX
          HapticFeedback.selectionClick();
        }
      },
      onPanEnd: (details) {
        _isPanning = false;
      },
      child: Stack(
        children: [
          widget.child,
          // Gesture feedback overlays
          _buildGestureFeedback(),
        ],
      ),
    );
  }

  Widget _buildGestureFeedback() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned.fill(
      child: Row(
        children: [
          // Left side - brightness indicator
          Expanded(
            child: Obx(() {
              final controller = Get.find<VideoPlayerController>();
              return AnimatedOpacity(
                opacity: controller.showBrightnessSlider ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: controller.showBrightnessSlider
                    ? _buildFeedbackIndicator(
                        context,
                        icon: Symbols.brightness_6_rounded,
                        value: controller.brightness,
                        label: 'Brightness',
                        colorScheme: colorScheme,
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
          // Right side - volume indicator
          Expanded(
            child: Obx(() {
              final controller = Get.find<VideoPlayerController>();
              return AnimatedOpacity(
                opacity: controller.showVolumeSlider ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: controller.showVolumeSlider
                    ? _buildFeedbackIndicator(
                        context,
                        icon: controller.volume > 0.5
                            ? Symbols.volume_up_rounded
                            : controller.volume > 0
                            ? Symbols.volume_down_rounded
                            : Symbols.volume_off_rounded,
                        value: controller.volume,
                        label: 'Volume',
                        colorScheme: colorScheme,
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackIndicator(
    BuildContext context, {
    required IconData icon,
    required double value,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${(value * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
