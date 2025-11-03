import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/widgets/common/loading_indicator.dart';
import '../controllers/video_player_controller.dart';
import 'video_error_widget.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    required this.videoTitle,
    required this.videoPath,
    super.key,
  });

  final String videoTitle;
  final String videoPath;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>();

    return Obx(() {
      if (controller.isLoading) {
        return _buildLoadingWidget();
      }

      if (controller.hasError) {
        return VideoErrorWidget(
          error: controller.errorMessage,
          onRetry: () => controller.retryInitialization(videoPath),
        );
      }

      if (!controller.isInitialized ||
          controller.betterPlayerController == null) {
        return _buildInitializingWidget();
      }

      return _buildVideoPlayer(controller);
    });
  }

  Widget _buildLoadingWidget() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitializingWidget() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.video_library_rounded,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Initializing player...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          // Better Player Video
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.aspectRatio,
                child: BetterPlayer(
                  controller: controller.betterPlayerController!,
                ),
              ),
            ),
          ),

          // Gesture detector for video area
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.toggleControls,
              onDoubleTap: () {
                if (controller.isFullScreen) {
                  controller.togglePlayPause();
                } else {
                  controller.toggleFullScreen();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // Gesture areas for seeking (only when controls are hidden)
          Obx(() {
            if (controller.gesturesEnabled && !controller.isControlsVisible) {
              return _buildGestureAreas(controller);
            }
            return const SizedBox.shrink();
          }),

          // Buffering indicator
          Obx(() {
            if (controller.isBuffering) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Buffering...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Video completed overlay
          Obx(() {
            if (controller.isCompleted && !controller.loopVideo) {
              return _buildCompletedOverlay(controller);
            }
            return const SizedBox.shrink();
          }),

          // Controls overlay
          Obx(() {
            if (controller.isControlsVisible) {
              return _buildControlsOverlay(controller);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCompletedOverlay(VideoPlayerController controller) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(
                Symbols.check_circle_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Video Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Symbols.replay_rounded,
                  label: 'Replay',
                  onPressed: controller.restart,
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Symbols.arrow_back_rounded,
                  label: 'Back',
                  onPressed: () => Get.back(),
                  isPrimary: false,
                ),
              ],
            ),
          ],
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
        border: isPrimary ? null : Border.all(color: Colors.white, width: 1.5),
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

  Widget _buildControlsOverlay(VideoPlayerController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(controller),
            Expanded(child: _buildCenterControls(controller)),
            _buildBottomControls(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildIconButton(
            icon: Symbols.arrow_back_rounded,
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.videoResolution.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.videoResolution,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          _buildIconButton(
            icon: Symbols.settings_rounded,
            onPressed: () => _showSettingsDialog(controller),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: controller.isFullScreen
                ? Symbols.fullscreen_exit_rounded
                : Symbols.fullscreen_rounded,
            onPressed: controller.toggleFullScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls(VideoPlayerController controller) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Symbols.replay_10_rounded,
            onPressed: controller.seekBackward,
          ),
          _buildPlayPauseButton(controller),
          _buildControlButton(
            icon: Symbols.forward_10_rounded,
            onPressed: controller.seekForward,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(VideoPlayerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.togglePlayPause();
          },
          borderRadius: BorderRadius.circular(35),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(
              controller.isPlaying
                  ? Symbols.pause_rounded
                  : Symbols.play_arrow_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressBar(controller),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedButton(controller),
              _buildVolumeButton(controller),
              _buildLoopButton(controller),
              _buildMoreButton(controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    return Obx(() {
      final position = controller.position;
      final duration = controller.duration;
      final progress = controller.progress;

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                controller.seekToPercentage(value);
              },
            ),
          ),
          const SizedBox(height: 8),
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
              if (controller.playbackSpeed != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
    });
  }

  Widget _buildSpeedButton(VideoPlayerController controller) {
    return PopupMenuButton<double>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Symbols.speed_rounded, color: Colors.white, size: 20),
      ),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: controller.setPlaybackSpeed,
      itemBuilder: (context) => controller.availableSpeeds
          .map(
            (speed) => PopupMenuItem(
              value: speed,
              child: Row(
                children: [
                  if (controller.playbackSpeed == speed)
                    const Icon(
                      Symbols.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  if (controller.playbackSpeed == speed)
                    const SizedBox(width: 8),
                  Text(
                    '${speed}x',
                    style: TextStyle(
                      color: controller.playbackSpeed == speed
                          ? Colors.white
                          : Colors.white70,
                      fontWeight: controller.playbackSpeed == speed
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildVolumeButton(VideoPlayerController controller) {
    return PopupMenuButton<double>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          controller.volume == 0
              ? Symbols.volume_off_rounded
              : controller.volume > 0.5
              ? Symbols.volume_up_rounded
              : Symbols.volume_down_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: controller.setVolume,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0.0,
          child: Row(
            children: [
              const Icon(
                Symbols.volume_off_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Mute',
                style: TextStyle(
                  color: controller.volume == 0.0
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: controller.volume == 0.0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...[0.25, 0.5, 0.75, 1.0].map(
          (volume) => PopupMenuItem(
            value: volume,
            child: Row(
              children: [
                if (controller.volume == volume)
                  const Icon(
                    Symbols.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                if (controller.volume == volume) const SizedBox(width: 8),
                Text(
                  '${(volume * 100).toInt()}%',
                  style: TextStyle(
                    color: controller.volume == volume
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: controller.volume == volume
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoopButton(VideoPlayerController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.setLoopVideo(!controller.loopVideo),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              controller.loopVideo
                  ? Symbols.repeat_on_rounded
                  : Symbols.repeat_rounded,
              color: controller.loopVideo ? Colors.blue : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(VideoPlayerController controller) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Symbols.more_vert_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'restart':
            controller.restart();
            break;
          case 'info':
            _showVideoInfo(controller);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'restart',
          child: Row(
            children: [
              Icon(
                Symbols.restart_alt_rounded,
                color: Colors.white70,
                size: 16,
              ),
              SizedBox(width: 8),
              Text('Restart', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Symbols.info_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Video Info', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestureAreas(VideoPlayerController controller) {
    return Row(
      children: [
        // Left side - seek backward
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              controller.seekBackward();
              controller.showControls();
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        // Right side - seek forward
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              controller.seekForward();
              controller.showControls();
            },
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(VideoPlayerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Video Settings',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingsTile(
              title: 'Auto-hide Controls',
              value: controller.autoHideControls,
              onChanged: controller.setAutoHideControls,
            ),
            _buildSettingsTile(
              title: 'Remember Position',
              value: controller.rememberPosition,
              onChanged: controller.setRememberPosition,
            ),
            _buildSettingsTile(
              title: 'Gesture Controls',
              value: controller.gesturesEnabled,
              onChanged: controller.setGesturesEnabled,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showVideoInfo(VideoPlayerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Video Information',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Resolution', controller.videoResolution),
            _infoRow('Duration', _formatDuration(controller.duration)),
            _infoRow('Position', _formatDuration(controller.position)),
            _infoRow(
              'Progress',
              '${(controller.progress * 100).toStringAsFixed(1)}%',
            ),
            _infoRow('Speed', '${controller.playbackSpeed}x'),
            _infoRow('Volume', '${(controller.volume * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
