import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/video_player_controller.dart';

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
      child: ColoredBox(
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
              return IgnorePointer(
                ignoring: !controller.isControlsVisible.value,
                child: AnimatedOpacity(
                  opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _VideoControlsOverlay(
                    videoTitle: widget.videoTitle,
                    controllerTag: widget.videoPath,
                  ),
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
    const sensitivity = 300.0; // Adjust sensitivity

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
      child: ColoredBox(
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

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
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 24 : 16,
                  vertical: isLandscape ? 8 : 12,
                ),
                child: Row(
                  children: [
                    _buildControlButton(
                      icon: Symbols.arrow_back_rounded,
                      filled: true,
                      onPressed: () {
                        if (controller.isFullScreen.value) {
                          controller.toggleFullscreen();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    if (!isLandscape)
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
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 16),
                    _buildControlButton(
                      icon: Symbols.more_vert_rounded,
                      filled: true,
                      onPressed: () => _showOptionsMenu(context, controller),
                    ),
                  ],
                ),
              ),
            ),

            // --- Center controls ---
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeekButton(
                    icon: Symbols.replay_10_rounded,
                    onPressed: () => controller.seekBackward(),
                  ),
                  SizedBox(width: isLandscape ? 80 : 60),
                  Obx(() => _buildPlayPauseButton(controller)),
                  SizedBox(width: isLandscape ? 80 : 60),
                  _buildSeekButton(
                    icon: Symbols.forward_10_rounded,
                    onPressed: () => controller.seekForward(),
                  ),
                ],
              ),
            ),

            // --- Bottom controls ---
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isLandscape ? 24 : 16,
                  8,
                  isLandscape ? 24 : 16,
                  isLandscape ? 8 : 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    Obx(() => _buildProgressBar(controller)),
                    SizedBox(height: isLandscape ? 8 : 16),
                    // Control buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.playlist.isNotEmpty) ...[
                              _buildControlButton(
                                icon: Symbols.skip_previous_rounded,
                                filled: true,
                                onPressed: controller.previousVideo,
                              ),
                              const SizedBox(width: 12),
                            ],
                            _buildControlButton(
                              icon: controller.isPlaying.value
                                  ? Symbols.pause_rounded
                                  : Symbols.play_arrow_rounded,
                              filled: true,
                              onPressed: controller.togglePlay,
                              size: 28,
                            ),
                            if (controller.playlist.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              _buildControlButton(
                                icon: Symbols.skip_next_rounded,
                                filled: true,
                                onPressed: controller.nextVideo,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLandscape)
                              _buildControlButton(
                                icon: Symbols.screenshot_rounded,
                                filled: true,
                                onPressed: controller.takeScreenshot,
                              ),
                            if (!isLandscape) const SizedBox(width: 12),
                            Obx(
                              () => _buildControlButton(
                                icon: controller.isFullScreen.value
                                    ? Symbols.fullscreen_exit_rounded
                                    : Symbols.fullscreen_rounded,
                                filled: true,
                                onPressed: controller.toggleFullscreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
    bool filled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(32),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size,
              fill: filled ? 1 : 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeekButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(48),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(48),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 40, fill: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(VideoPlayerController controller) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: controller.isPlaying.value
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(56),
        child: InkWell(
          onTap: controller.togglePlay,
          borderRadius: BorderRadius.circular(56),
          splashColor: Colors.white.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.25),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: Icon(
              controller.isPlaying.value
                  ? Symbols.pause_rounded
                  : Symbols.play_arrow_rounded,
              color: Colors.white,
              size: 48,
              fill: 1,
              weight: 300,
            ),
          ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _formatDuration(pos),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 4,
                      pressedElevation: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                    overlayColor: Colors.white.withValues(alpha: 0.25),
                    trackHeight: 6,
                    trackShape: const RoundedRectSliderTrackShape(),
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _formatDuration(dur),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Symbols.settings_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Video Options',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Options list
            _buildOptionTile(
              context,
              icon: Symbols.speed_rounded,
              title: 'Playback Speed',
              subtitle: '${controller.speed.value}x',
              onTap: () => _showSpeedOptions(context),
            ),
            Obx(
              () => _buildOptionTile(
                context,
                icon: controller.volume.value == 0
                    ? Symbols.volume_off_rounded
                    : Symbols.volume_up_rounded,
                title: 'Volume',
                subtitle: '${(controller.volume.value * 100).round()}%',
                onTap: () => _showVolumeSlider(context),
              ),
            ),
            _buildOptionTile(
              context,
              icon: Symbols.info_rounded,
              title: 'Video Info',
              subtitle: 'Details about this video',
              onTap: () => _showVideoInfo(context),
            ),

            const Divider(height: 32, indent: 24, endIndent: 24),

            // Switches
            Obx(
              () => _buildSwitchTile(
                context,
                icon: Symbols.loop_rounded,
                title: 'Loop Video',
                subtitle: 'Repeat when finished',
                value: controller.loop.value,
                onChanged: controller.setLoop,
              ),
            ),
            Obx(
              () => _buildSwitchTile(
                context,
                icon: Symbols.gesture_rounded,
                title: 'Gesture Controls',
                subtitle: 'Swipe to adjust volume & brightness',
                value: controller.gesturesEnabled.value,
                onChanged: controller.setGesturesEnabled,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onTertiaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedOptions(BuildContext context) {
    Navigator.pop(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Symbols.speed_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Playback Speed',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Speed options
              ...controller.speeds.map(
                (speed) => Obx(() {
                  final isSelected = controller.speed.value == speed;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Material(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          controller.setSpeed(speed);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${speed}x',
                                    style: TextStyle(
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme
                                                .colorScheme
                                                .onSecondaryContainer,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  speed == 1.0
                                      ? 'Normal'
                                      : speed < 1.0
                                      ? 'Slower'
                                      : 'Faster',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : null,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Symbols.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                  fill: 1,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context) {
    Navigator.pop(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Symbols.volume_up_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Volume Control',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Volume slider
            Obx(() {
              final volumeIcon = controller.volume.value == 0
                  ? Symbols.volume_off_rounded
                  : controller.volume.value < 0.3
                  ? Symbols.volume_mute_rounded
                  : controller.volume.value < 0.7
                  ? Symbols.volume_down_rounded
                  : Symbols.volume_up_rounded;

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            volumeIcon,
                            color: theme.colorScheme.onSecondaryContainer,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                                elevation: 4,
                              ),
                              overlayShape: const RoundSliderOverlayShape(),
                            ),
                            child: Slider(
                              value: controller.volume.value,
                              onChanged: controller.setVolume,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(controller.volume.value * 100).round()}%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }

  void _showVideoInfo(BuildContext context) {
    Navigator.pop(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Symbols.info_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Video Information',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Info cards
            Obx(
              () => Column(
                children: [
                  _buildInfoCard(
                    context,
                    icon: Symbols.schedule_rounded,
                    label: 'Duration',
                    value: _formatDuration(controller.duration.value),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Symbols.high_quality_rounded,
                    label: 'Resolution',
                    value: controller.resolution.value.isEmpty
                        ? 'Unknown'
                        : controller.resolution.value,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Symbols.aspect_ratio_rounded,
                    label: 'Aspect Ratio',
                    value:
                        '${controller.aspectRatio.value.toStringAsFixed(2)}:1',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Symbols.speed_rounded,
                    label: 'Playback Speed',
                    value: '${controller.speed.value}x',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Symbols.volume_up_rounded,
                    label: 'Volume',
                    value: '${(controller.volume.value * 100).round()}%',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Symbols.play_circle_rounded,
                    label: 'Current Position',
                    value: _formatDuration(controller.position.value),
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSecondaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
