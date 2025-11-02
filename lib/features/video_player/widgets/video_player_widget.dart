import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

      if (!controller.isInitialized || controller.player == null) {
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
            Text('Loading video...', style: TextStyle(color: Colors.white)),
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
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Initializing player...',
              style: TextStyle(color: Colors.white54),
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
          // Video player using Media Kit - always visible
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Video(
                  controller: VideoController(controller.player!),
                  controls: NoVideoControls, // We use custom controls
                  // fit: BoxFit.contain is the default
                ),
              ),
            ),
          ),

          // Gesture detector for video area (behind controls)
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.toggleControls,
              onDoubleTap: () {
                // Smart double-tap: fullscreen in portrait, play/pause in landscape
                if (controller.isLandscape) {
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
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Buffering indicator
          Obx(() {
            if (controller.isBuffering) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 8),
                    Text(
                      'Buffering...',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Video completed overlay
          Obx(() {
            if (controller.isCompleted && !controller.loopVideo) {
              return _buildCompletedOverlay(controller);
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Debug indicator when controls are hidden
          Obx(() {
            if (!controller.isControlsVisible) {
              return Positioned(
                top: 50,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Controls Hidden - Video Should Be Visible',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Controls overlay (on top, fully interactive)
          Obx(() {
            if (controller.isControlsVisible) {
              return _buildControlsOverlay(controller);
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCompletedOverlay(VideoPlayerController controller) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Symbols.check_circle_rounded,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.restart,
                  icon: const Icon(Symbols.replay_rounded),
                  label: const Text('Replay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Symbols.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
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
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(controller),

            // Center controls
            Expanded(child: _buildCenterControls(controller)),

            // Bottom controls
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
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.videoResolution.isNotEmpty)
                  Text(
                    controller.videoResolution,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          // Settings button
          IconButton(
            onPressed: () => _showSettingsDialog(controller),
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          // Fullscreen button
          IconButton(
            onPressed: controller.toggleFullScreen,
            icon: Icon(
              controller.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(VideoPlayerController controller) {
    return Stack(
      children: [
        // Background area that can be tapped to hide controls
        Positioned.fill(
          child: GestureDetector(
            onTap: controller.toggleControls,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Control buttons on top
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.replay_10,
                onPressed: controller.seekBackward,
              ),
              _buildPlayPauseButton(controller),
              _buildControlButton(
                icon: Icons.forward_10,
                onPressed: controller.seekForward,
              ),
            ],
          ),
        ),
      ],
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
      child: IconButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        icon: Icon(icon, color: Colors.white, size: 32),
        iconSize: 48,
      ),
    );
  }

  Widget _buildPlayPauseButton(VideoPlayerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          controller.togglePlayPause();
        },
        icon: Icon(
          controller.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        iconSize: 64,
      ),
    );
  }

  Widget _buildBottomControls(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(controller),
          const SizedBox(height: 16),

          // Control buttons
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
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                controller.seekToPercentage(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (controller.playbackSpeed != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${controller.playbackSpeed}x',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSpeedButton(VideoPlayerController controller) {
    return PopupMenuButton<double>(
      icon: const Icon(Icons.speed, color: Colors.white),
      color: Colors.grey[900],
      onSelected: controller.setPlaybackSpeed,
      itemBuilder: (context) => controller.availableSpeeds
          .map(
            (speed) => PopupMenuItem(
              value: speed,
              child: Row(
                children: [
                  if (controller.playbackSpeed == speed)
                    const Icon(Icons.check, color: Colors.white, size: 16),
                  if (controller.playbackSpeed == speed)
                    const SizedBox(width: 8),
                  Text(
                    '${speed}x',
                    style: TextStyle(
                      color: controller.playbackSpeed == speed
                          ? Colors.white
                          : Colors.white70,
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
      icon: Icon(
        controller.isMuted || controller.volume == 0
            ? Icons.volume_off
            : controller.volume > 50
            ? Icons.volume_up
            : Icons.volume_down,
        color: Colors.white,
      ),
      color: Colors.grey[900],
      onSelected: controller.setVolume,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0.0,
          child: Row(
            children: [
              Icon(Icons.volume_off, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Mute', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...([25.0, 50.0, 75.0, 100.0].map(
          (volume) => PopupMenuItem(
            value: volume,
            child: Row(
              children: [
                if (controller.volume == volume)
                  const Icon(Icons.check, color: Colors.white, size: 16),
                if (controller.volume == volume) const SizedBox(width: 8),
                Text(
                  '${volume.toInt()}%',
                  style: TextStyle(
                    color: controller.volume == volume
                        ? Colors.white
                        : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildLoopButton(VideoPlayerController controller) {
    return IconButton(
      onPressed: () => controller.setLoopVideo(!controller.loopVideo),
      icon: Icon(
        controller.loopVideo ? Icons.repeat_on : Icons.repeat,
        color: controller.loopVideo ? Colors.blue : Colors.white,
      ),
    );
  }

  Widget _buildMoreButton(VideoPlayerController controller) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: Colors.grey[900],
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
              Icon(Icons.restart_alt, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Restart', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Video Info', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestureAreas(VideoPlayerController controller) {
    return Positioned.fill(
      child: Row(
        children: [
          // Left side - seek backward
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                controller.seekBackward();
                // Show controls briefly to give feedback
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
                // Show controls briefly to give feedback
                controller.showControls();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(VideoPlayerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Video Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text(
                'Auto-hide Controls',
                style: TextStyle(color: Colors.white70),
              ),
              value: controller.autoHideControls,
              onChanged: controller.setAutoHideControls,
              activeThumbColor: Colors.blue,
            ),
            SwitchListTile(
              title: const Text(
                'Remember Position',
                style: TextStyle(color: Colors.white70),
              ),
              value: controller.rememberPosition,
              onChanged: controller.setRememberPosition,
              activeThumbColor: Colors.blue,
            ),
            SwitchListTile(
              title: const Text(
                'Gesture Controls',
                style: TextStyle(color: Colors.white70),
              ),
              value: controller.gesturesEnabled,
              onChanged: controller.setGesturesEnabled,
              activeThumbColor: Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showVideoInfo(VideoPlayerController controller) {
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
            _infoRow('Resolution', controller.videoResolution),
            _infoRow('Duration', _formatDuration(controller.duration)),
            _infoRow('Position', _formatDuration(controller.position)),
            _infoRow(
              'Progress',
              '${(controller.progress * 100).toStringAsFixed(1)}%',
            ),
            _infoRow('Speed', '${controller.playbackSpeed}x'),
            _infoRow('Volume', '${controller.volume.toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
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
