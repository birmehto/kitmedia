import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../routes/app_routes.dart';
import '../controllers/video_player_controller.dart';

class VideoControlsOverlay extends StatelessWidget {
  const VideoControlsOverlay({
    required this.videoTitle,
    this.videoPath,
    super.key,
  });
  final String videoTitle;
  final String? videoPath;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>();

    return Obx(() {
      if (!controller.isInitialized ||
          controller.videoPlayerController == null) {
        return const SizedBox.shrink();
      }

      return AnimatedBuilder(
        animation: controller.controlsAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: controller.controlsAnimation.value,
            child: controller.isControlsVisible
                ? _buildControlsContent(controller)
                : const SizedBox.shrink(),
          );
        },
      );
    });
  }

  Widget _buildControlsContent(VideoPlayerController controller) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Column(
            children: [
              _buildTopBar(controller),
              const Spacer(),
              _buildCenterControls(controller),
              const Spacer(),
              _buildBottomControls(controller),
            ],
          ),
        ),
        // Side sliders
        _buildSideSliders(controller),
        // Speed selector
        _buildSpeedSelector(controller),
        // Buffering indicator
        _buildBufferingIndicator(controller),
      ],
    );
  }

  Widget _buildTopBar(VideoPlayerController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Material 3 back button with surface container
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: const Icon(
                Symbols.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => AppRoutes.goBack(),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (videoPath != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getVideoInfo(controller),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildTopBarActions(controller),
        ],
      ),
    );
  }

  Widget _buildTopBarActions(VideoPlayerController controller) {
    return Row(
      children: [
        // Material 3 fullscreen button
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: Icon(
              controller.isFullScreen
                  ? Symbols.fullscreen_exit_rounded
                  : Symbols.fullscreen_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: controller.toggleFullScreen,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Material 3 menu button
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Symbols.more_vert_rounded,
              color: Colors.white,
              size: 24,
            ),
            color: const Color(0xFF1C1B1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            onSelected: (value) => _handleMenuAction(value, controller),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(
                      Symbols.info,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Video Info',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'quality',
                child: Row(
                  children: [
                    Icon(
                      Symbols.high_quality_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Quality',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'subtitles',
                child: Row(
                  children: [
                    Icon(
                      Symbols.subtitles_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Subtitles',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterControls(VideoPlayerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSeekButton(
          icon: Symbols.replay_10_rounded,
          onPressed: controller.seekBackward,
        ),
        ValueListenableBuilder(
          valueListenable: controller.videoPlayerController!,
          builder: (context, value, child) {
            final isPlaying = value.isPlaying;
            return GestureDetector(
              onTap: controller.togglePlayPause,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying
                      ? Symbols.pause_rounded
                      : Symbols.play_arrow_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            );
          },
        ),
        _buildSeekButton(
          icon: Symbols.forward_10_rounded,
          onPressed: controller.seekForward,
        ),
      ],
    );
  }

  Widget _buildSeekButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerController controller) {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: controller.videoPlayerController!,
            builder: (context, value, child) {
              final position = value.position;
              final duration = value.duration;

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(elevation: 2),
                      trackHeight: 5,
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0,
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds: (value * duration.inMilliseconds)
                              .round(),
                        );
                        controller.seekTo(newPosition);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${controller.playbackSpeed}x',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Symbols.volume_up_rounded,
                onPressed: controller.toggleVolumeSlider,
                isActive: controller.showVolumeSlider,
              ),
              _buildControlButton(
                icon: Symbols.brightness_6_rounded,
                onPressed: controller.toggleBrightnessSlider,
                isActive: controller.showBrightnessSlider,
              ),
              _buildControlButton(
                icon: Symbols.speed_rounded,
                onPressed: controller.toggleSpeedSelector,
                isActive: controller.showSpeedSelector,
              ),
              ValueListenableBuilder(
                valueListenable: controller.videoPlayerController!,
                builder: (context, value, child) {
                  final isPlaying = value.isPlaying;
                  return _buildControlButton(
                    icon: isPlaying
                        ? Symbols.pause_rounded
                        : Symbols.play_arrow_rounded,
                    onPressed: controller.togglePlayPause,
                    isPrimary: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? colorScheme.primary : Colors.white,
          size: isPrimary ? 28 : 22,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all(isPrimary ? 14 : 12),
        style: IconButton.styleFrom(
          minimumSize: Size(isPrimary ? 56 : 48, isPrimary ? 56 : 48),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  Widget _buildSideSliders(VideoPlayerController controller) {
    return Positioned.fill(
      child: Row(
        children: [
          // Brightness slider (left side)
          Obx(
            () => controller.showBrightnessSlider
                ? _buildVerticalSlider(
                    value: controller.brightness,
                    onChanged: controller.setBrightness,
                    icon: Symbols.brightness_6_rounded,
                    label: 'Brightness',
                    isLeft: true,
                  )
                : const SizedBox.shrink(),
          ),

          const Spacer(),

          // Volume slider (right side)
          Obx(
            () => controller.showVolumeSlider
                ? _buildVerticalSlider(
                    value: controller.volume,
                    onChanged: controller.setVolume,
                    icon: Symbols.volume_up_rounded,
                    label: 'Volume',
                    isLeft: false,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSlider({
    required double value,
    required Function(double) onChanged,
    required IconData icon,
    required String label,
    required bool isLeft,
  }) {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(
        left: isLeft ? 20 : 0,
        right: isLeft ? 0 : 20,
        top: 100,
        bottom: 150,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: Colors.white30,
                  thumbColor: colorScheme.primary,
                  overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(value: value, onChanged: onChanged),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator(VideoPlayerController controller) {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    return Obx(
      () => controller.isBuffering
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSpeedSelector(VideoPlayerController controller) {
    if (!controller.showSpeedSelector) return const SizedBox.shrink();

    return Positioned(
      bottom: 120,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Playback Speed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.playbackSpeeds.map((speed) {
              final isSelected = controller.playbackSpeed == speed;
              return GestureDetector(
                onTap: () {
                  controller.setPlaybackSpeed(speed);
                  controller.toggleSpeedSelector();
                },
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            Get.context!,
                          ).colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(
                              Get.context!,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                          )
                        : null,
                  ),
                  child: Text(
                    '${speed}x',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(Get.context!).colorScheme.primary
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getVideoInfo(VideoPlayerController controller) {
    if (controller.videoPlayerController == null) return '';

    final size = controller.videoPlayerController!.value.size;
    final duration = controller.videoPlayerController!.value.duration;

    return '${size.width.toInt()}x${size.height.toInt()} • ${_formatDuration(duration)}';
  }

  void _handleMenuAction(String action, VideoPlayerController controller) {
    switch (action) {
      case 'info':
        _showVideoInfo(controller);
        break;
      case 'quality':
        _showQualitySelector(controller);
        break;
      case 'subtitles':
        _showSubtitleOptions(controller);
        break;
    }
  }

  void _showVideoInfo(VideoPlayerController controller) {
    if (controller.videoPlayerController == null) return;

    final videoController = controller.videoPlayerController!;
    final size = videoController.value.size;
    final duration = videoController.value.duration;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Video Information',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', videoTitle),
            _buildInfoRow(
              'Resolution',
              '${size.width.toInt()}x${size.height.toInt()}',
            ),
            _buildInfoRow('Duration', _formatDuration(duration)),
            _buildInfoRow(
              'Aspect Ratio',
              videoController.value.aspectRatio.toStringAsFixed(2),
            ),
            if (videoPath != null) ...[_buildInfoRow('Path', videoPath!)],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showQualitySelector(VideoPlayerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Video Quality',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.videoQualities.map((quality) {
            final isSelected = controller.videoQuality == quality;
            return ListTile(
              title: Text(
                quality,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(Get.context!).colorScheme.primary
                      : Colors.white,
                ),
              ),
              leading: Icon(
                isSelected
                    ? Symbols.radio_button_checked
                    : Symbols.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(Get.context!).colorScheme.primary
                    : Colors.white,
              ),
              onTap: () {
                // Quality change logic would go here
                Get.back();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubtitleOptions(VideoPlayerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Subtitles', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Off', style: TextStyle(color: Colors.white)),
              leading: Icon(
                Symbols.radio_button_checked,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
            const ListTile(
              title: Text(
                'Auto-generated',
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Symbols.radio_button_unchecked,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
