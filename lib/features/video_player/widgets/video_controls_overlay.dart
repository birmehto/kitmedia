import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/widgets/common/loading_indicator.dart';
import '../controllers/video_player_controller.dart';
import 'video_controls.dart';

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
    return Stack(
      children: [
        // Main player controls
        EnhancedVideoControls(videoTitle: videoTitle, videoPath: videoPath),

        // Side sliders (volume + brightness)
        _buildSideOverlays(),

        // Speed selector
        _buildSpeedSelector(),

        // Buffering indicator
        _buildBufferingIndicator(),
      ],
    );
  }

  Widget _buildSideOverlays() {
    return Obx(() {
      final controller = Get.find<VideoPlayerController>();
      return Stack(
        children: [
          if (controller.showBrightnessSlider)
            _buildVerticalSlider(
              value: controller.brightness,
              onChanged: controller.setBrightness,
              icon: Symbols.brightness_6_rounded,
              label: 'Brightness',
              isLeft: true,
            ),
          if (controller.showVolumeSlider)
            _buildVerticalSlider(
              value: controller.volume,
              onChanged: controller.setVolume,
              icon: Symbols.volume_up_rounded,
              label: 'Volume',
              isLeft: false,
            ),
        ],
      );
    });
  }

  Widget _buildVerticalSlider({
    required double value,
    required Function(double) onChanged,
    required IconData icon,
    required String label,
    required bool isLeft,
  }) {
    return Positioned(
      left: isLeft ? 20 : null,
      right: isLeft ? null : 20,
      top: 100,
      bottom: 150,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(height: 10),
                  RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Slider(
                        value: value.clamp(0, 1),
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSelector() {
    return Obx(() {
      final controller = Get.find<VideoPlayerController>();
      if (!controller.showSpeedSelector) return const SizedBox.shrink();

      return Positioned(
        bottom: 140,
        right: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.speed_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Speed',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...controller.playbackSpeeds.map((speed) {
                    final isSelected = controller.playbackSpeed == speed;
                    return GestureDetector(
                      onTap: () {
                        controller.setPlaybackSpeed(speed);
                        controller.toggleSpeedSelector();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: Colors.white70)
                              : null,
                        ),
                        child: Text(
                          '${speed.toStringAsFixed(1)}×',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBufferingIndicator() {
    return Obx(() {
      final controller = Get.find<VideoPlayerController>();
      if (!controller.isBuffering) return const SizedBox.shrink();

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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}
