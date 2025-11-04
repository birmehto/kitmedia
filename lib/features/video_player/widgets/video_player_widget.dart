import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/video_player_controller.dart';
import 'video_playlist_widget.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });

  final String videoPath;
  final String videoTitle;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  double? _initialBrightness;
  double? _initialVolume;
  bool _isDragging = false;
  bool _isVolumeGesture = false;
  bool _isBrightnessGesture = false;
  double _gestureStartY = 0;
  double _gestureCurrentY = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>(tag: widget.videoPath);
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: controller.toggleControls,
      onDoubleTap: controller.togglePlay,
      onPanStart: (details) => _onPanStart(details, screenSize, controller),
      onPanUpdate: (details) => _onPanUpdate(details, controller),
      onPanEnd: (details) => _onPanEnd(details, controller),
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Better Player view ---
            Obx(() {
              if (controller.hasError.value) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.error_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.isLoading.value || controller.player == null) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Loading video...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              return AspectRatio(
                aspectRatio: controller.aspectRatio.value,
                child: BetterPlayer(controller: controller.player!),
              );
            }),

            // --- Loading or buffering spinner ---
            Obx(() {
              if (controller.isBuffering.value) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Buffering...',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // --- Gesture feedback overlay ---
            if (_isDragging) _buildGestureFeedback(controller),

            // --- Overlay controls ---
            Obx(() {
              if (!controller.isControlsVisible.value) {
                return const SizedBox.shrink();
              }

              return AnimatedOpacity(
                opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _VideoControlsOverlay(
                  videoTitle: widget.videoTitle,
                  controllerTag: widget.videoPath,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onPanStart(
    DragStartDetails details,
    Size screenSize,
    VideoPlayerController controller,
  ) {
    if (!controller.gesturesEnabled.value) return;

    _gestureStartY = details.globalPosition.dy;
    _gestureCurrentY = _gestureStartY;
    _isDragging = true;

    // Determine if this is a volume or brightness gesture based on screen side
    final isLeftSide = details.globalPosition.dx < screenSize.width / 2;
    _isBrightnessGesture = isLeftSide;
    _isVolumeGesture = !isLeftSide;

    // Store initial values
    if (_isBrightnessGesture) {
      _initialBrightness = controller.brightness.value;
    } else if (_isVolumeGesture) {
      _initialVolume = controller.volume.value;
    }

    setState(() {});
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    VideoPlayerController controller,
  ) {
    if (!controller.gesturesEnabled.value || !_isDragging) return;

    _gestureCurrentY = details.globalPosition.dy;
    final deltaY = _gestureStartY - _gestureCurrentY;
    final sensitivity = 300.0; // Adjust sensitivity

    if (_isBrightnessGesture && _initialBrightness != null) {
      final newBrightness = (_initialBrightness! + (deltaY / sensitivity))
          .clamp(0.0, 1.0);
      controller.setBrightness(newBrightness);
    } else if (_isVolumeGesture && _initialVolume != null) {
      final newVolume = (_initialVolume! + (deltaY / sensitivity)).clamp(
        0.0,
        1.0,
      );
      controller.setVolume(newVolume);
    }

    setState(() {});
  }

  void _onPanEnd(DragEndDetails details, VideoPlayerController controller) {
    _isDragging = false;
    _isBrightnessGesture = false;
    _isVolumeGesture = false;
    _initialBrightness = null;
    _initialVolume = null;
    setState(() {});
  }

  Widget _buildGestureFeedback(VideoPlayerController controller) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              if (_isBrightnessGesture) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Symbols.brightness_6,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Brightness: ${(controller.brightness.value * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: controller.brightness.value,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (_isVolumeGesture) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.volume.value == 0
                          ? Symbols.volume_off
                          : controller.volume.value < 0.5
                          ? Symbols.volume_down
                          : Symbols.volume_up,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Volume: ${(controller.volume.value * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: controller.volume.value,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
      ),
    );
  }
}

class _VideoControlsOverlay extends StatefulWidget {
  const _VideoControlsOverlay({
    required this.videoTitle,
    required this.controllerTag,
  });

  final String videoTitle;
  final String controllerTag;

  @override
  State<_VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<_VideoControlsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>(
      tag: widget.controllerTag,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Top bar ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildControlButton(
                      icon: Symbols.arrow_back_rounded,
                      onPressed: () {
                        if (controller.isFullScreen.value) {
                          controller.toggleFullscreen();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.videoTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Obx(() {
                            if (controller.resolution.value.isNotEmpty) {
                              return Text(
                                controller.resolution.value,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildControlButton(
                      icon: Symbols.more_vert_rounded,
                      onPressed: () => _showOptionsMenu(context, controller),
                    ),
                  ],
                ),
              ),
            ),

            // --- Center controls ---
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSeekButton(
                    icon: Symbols.replay_10_rounded,
                    onPressed: () => controller.seekBackward(),
                  ),
                  Obx(() => _buildPlayPauseButton(controller)),
                  _buildSeekButton(
                    icon: Symbols.forward_10_rounded,
                    onPressed: () => controller.seekForward(),
                  ),
                ],
              ),
            ),

            // --- Bottom controls ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar with preview
                  Obx(() => _buildProgressBar(controller)),
                  const SizedBox(height: 16),
                  // Control buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Symbols.skip_previous_rounded,
                        onPressed: controller.previousVideo,
                        size: 24,
                      ),
                      _buildControlButton(
                        icon: controller.isPlaying.value
                            ? Symbols.pause_rounded
                            : Symbols.play_arrow_rounded,
                        onPressed: controller.togglePlay,
                        size: 28,
                      ),
                      _buildControlButton(
                        icon: Symbols.skip_next_rounded,
                        onPressed: controller.nextVideo,
                        size: 24,
                      ),
                      _buildControlButton(
                        icon: Symbols.playlist_play_rounded,
                        onPressed: () => _showPlaylist(context),
                        size: 24,
                      ),
                      _buildControlButton(
                        icon: Symbols.screenshot_rounded,
                        onPressed: controller.takeScreenshot,
                        size: 24,
                      ),
                      Obx(
                        () => _buildControlButton(
                          icon: controller.isFullScreen.value
                              ? Symbols.fullscreen_exit_rounded
                              : Symbols.fullscreen_rounded,
                          onPressed: controller.toggleFullscreen,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 24,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildSeekButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildPlayPauseButton(VideoPlayerController controller) {
    return GestureDetector(
      onTap: controller.togglePlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: controller.isPlaying.value ? Colors.black54 : Colors.white24,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          controller.isPlaying.value
              ? Symbols.pause_rounded
              : Symbols.play_arrow_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    final pos = controller.position.value;
    final dur = controller.duration.value;
    final progress = dur.inMilliseconds > 0
        ? pos.inMilliseconds / dur.inMilliseconds
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Text(
              _formatDuration(pos),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (dur.inMilliseconds * value).round(),
                      );
                      controller.seek(newPosition);
                    },
                  ),
                ),
              ),
            ),
            Text(
              _formatDuration(dur),
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
  }

  void _showOptionsMenu(
    BuildContext context,
    VideoPlayerController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoOptionsSheet(controller: controller),
    );
  }

  void _showPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          VideoPlaylistWidget(controllerTag: widget.controllerTag),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _VideoOptionsSheet extends StatelessWidget {
  const _VideoOptionsSheet({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Video Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildOptionTile(
            icon: Symbols.speed_rounded,
            title: 'Playback Speed',
            subtitle: '${controller.speed.value}x',
            onTap: () => _showSpeedOptions(context),
          ),
          Obx(
            () => _buildOptionTile(
              icon: controller.volume.value == 0
                  ? Symbols.volume_off_rounded
                  : Symbols.volume_up_rounded,
              title: 'Volume',
              subtitle: '${(controller.volume.value * 100).round()}%',
              onTap: () => _showVolumeSlider(context),
            ),
          ),
          _buildOptionTile(
            icon: Symbols.info_rounded,
            title: 'Video Info',
            subtitle: 'Details about this video',
            onTap: () => _showVideoInfo(context),
          ),
          Obx(
            () => _buildSwitchTile(
              icon: Symbols.loop_rounded,
              title: 'Loop Video',
              value: controller.loop.value,
              onChanged: controller.setLoop,
            ),
          ),
          Obx(
            () => _buildSwitchTile(
              icon: Symbols.gesture_rounded,
              title: 'Gesture Controls',
              value: controller.gesturesEnabled.value,
              onChanged: controller.setGesturesEnabled,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(
        Symbols.chevron_right_rounded,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
      ),
    );
  }

  void _showSpeedOptions(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Playback Speed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...controller.speeds.map(
              (speed) => Obx(
                () => ListTile(
                  title: Text(
                    '${speed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: controller.speed.value == speed
                      ? const Icon(Symbols.check_rounded, color: Colors.white)
                      : null,
                  onTap: () {
                    controller.setSpeed(speed);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Volume Control',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => Row(
                children: [
                  Icon(
                    controller.volume.value == 0
                        ? Symbols.volume_off_rounded
                        : Symbols.volume_up_rounded,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Slider(
                      value: controller.volume.value,
                      onChanged: controller.setVolume,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                  Text(
                    '${(controller.volume.value * 100).round()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showVideoInfo(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Video Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Duration',
                    _formatDuration(controller.duration.value),
                  ),
                  _buildInfoRow('Resolution', controller.resolution.value),
                  _buildInfoRow(
                    'Aspect Ratio',
                    '${controller.aspectRatio.value.toStringAsFixed(2)}:1',
                  ),
                  _buildInfoRow('Current Speed', '${controller.speed.value}x'),
                  _buildInfoRow(
                    'Volume',
                    '${(controller.volume.value * 100).round()}%',
                  ),
                  _buildInfoRow(
                    'Position',
                    _formatDuration(controller.position.value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value.isEmpty ? 'Unknown' : value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
