import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/core.dart';
import '../../../core/services/system_controls.dart';

class VideoPlayerController extends BaseController
    with GetTickerProviderStateMixin {
  // Core video player components
  BaseVideoPlayerController? _baseController;
  vp.VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Animation controllers
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  // System controls service
  late SystemControls _systemControls;

  // UI state
  final RxBool _isControlsVisible = true.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isFullScreen = false.obs;
  final RxBool _isBuffering = false.obs;

  // Media controls
  final RxDouble _brightness = 0.5.obs;
  final RxDouble _volume = 1.0.obs;
  final RxDouble _playbackSpeed = 1.0.obs;

  // Overlay controls
  final RxBool _showVolumeSlider = false.obs;
  final RxBool _showBrightnessSlider = false.obs;
  final RxBool _showSpeedSelector = false.obs;

  // Getters
  BaseVideoPlayerController? get baseController => _baseController;
  vp.VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ChewieController? get chewieController => _chewieController;
  Animation<double> get controlsAnimation => _controlsAnimation;
  bool get isControlsVisible => _isControlsVisible.value;
  bool get isInitialized => _isInitialized.value;
  bool get isFullScreen => _isFullScreen.value;
  double get brightness => _brightness.value;
  double get volume => _volume.value;
  double get playbackSpeed => _playbackSpeed.value;
  bool get isBuffering => _isBuffering.value;
  bool get showVolumeSlider => _showVolumeSlider.value;
  bool get showBrightnessSlider => _showBrightnessSlider.value;
  bool get showSpeedSelector => _showSpeedSelector.value;

  // Available playback speeds
  final List<double> playbackSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  // Constants
  static const List<String> videoQualities = [
    'Auto',
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeSystemControls();
    CrossPlatformVideoPlayer.initialize();
    _enableWakelock();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      appLog('Could not enable wakelock: $e', color: 'yellow');
    }
  }

  Future<void> _initializeSystemControls() async {
    await executeSilently(() async {
      _systemControls = SystemControls.instance;
      await _systemControls.initialize();

      _brightness.value = _systemControls.currentBrightness;
      _volume.value = _systemControls.currentVolume;

      // Check if controls are available
      final hasBrightness = await _systemControls.hasBrightnessControl;
      final hasVolume = await _systemControls.hasVolumeControl;

      appLog(
        'System controls available - Brightness: $hasBrightness, Volume: $hasVolume',
      );
    });

    // Use fallback values if initialization failed
    if (hasError) {
      _brightness.value = 0.5;
      _volume.value = 0.5;
      clearError();
    }
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlsAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _controlsAnimationController.forward();
  }

  Future<void> initializePlayer(String videoPath) async {
    await executeWithLoading(() async {
      final file = File(videoPath);
      if (!file.existsSync()) {
        throw Exception('Video file not found: $videoPath');
      }

      _isInitialized.value = false;

      try {
        // Create and initialize video controller
        _baseController = VideoPlayerControllerFactory.create();
        await _baseController!.initialize(videoPath);

        // Setup Chewie for mobile platforms
        if (CrossPlatformVideoPlayer.isMobile &&
            _baseController is MobileVideoPlayerController) {
          _setupMobilePlayer();
        }

        _isInitialized.value = true;
        hideControlsAfterDelay();
      } catch (e) {
        // Handle various platform-specific errors
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('channel-error') ||
            errorString.contains('platformexception') ||
            errorString.contains('missingpluginexception') ||
            errorString.contains('sqflite') ||
            errorString.contains('database')) {
          throw Exception(
            'Video player initialization failed. This may be due to missing platform dependencies or running on an emulator.',
          );
        }
        rethrow;
      }
    });
  }

  void _setupMobilePlayer() {
    final mobileController = _baseController as MobileVideoPlayerController;
    _videoPlayerController = mobileController.videoPlayerController;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      showControls: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      errorBuilder: _buildErrorWidget,
    );

    _videoPlayerController!.addListener(_videoPlayerListener);
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void toggleControls() {
    _isControlsVisible.value = !_isControlsVisible.value;
    if (_isControlsVisible.value) {
      _controlsAnimationController.forward();
      hideControlsAfterDelay();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isControlsVisible.value &&
          _videoPlayerController != null &&
          _videoPlayerController!.value.isPlaying) {
        toggleControls();
      }
    });
  }

  void togglePlayPause() {
    if (_baseController == null) return;

    if (_baseController!.isPlaying) {
      _baseController!.pause();
    } else {
      _baseController!.play();
      hideControlsAfterDelay();
    }
  }

  void seekTo(Duration position) {
    _baseController?.seekTo(position);
  }

  void seekBackward() {
    if (_baseController == null) return;

    final currentPosition = _baseController!.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    seekTo(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void seekForward() {
    if (_baseController == null) return;

    final currentPosition = _baseController!.position;
    final duration = _baseController!.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    seekTo(newPosition > duration ? duration : newPosition);
  }

  void _videoPlayerListener() {
    if (_videoPlayerController != null) {
      _isBuffering.value = _videoPlayerController!.value.isBuffering;
    }
  }

  Future<void> setBrightness(double value) async {
    final clampedValue = value.clamp(0.0, 1.0);
    _brightness.value = clampedValue;

    await executeSilently(() async {
      await _systemControls.setBrightness(clampedValue);
    });

    _showBrightnessSlider.value = true;
    _hideSliderAfterDelay();
  }

  Future<void> setVolume(double value) async {
    final clampedValue = value.clamp(0.0, 1.0);
    _volume.value = clampedValue;

    // Try system volume first, fallback to video player volume
    await executeSilently(() async {
      await _systemControls.setVolume(clampedValue);
    });

    // Always set video player volume as fallback
    _baseController?.setVolume(clampedValue);

    _showVolumeSlider.value = true;
    _hideSliderAfterDelay();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed.value = speed;
    _baseController?.setPlaybackSpeed(speed);
  }

  /// Mute/unmute volume
  Future<void> toggleMute() async {
    if (_volume.value > 0) {
      // Mute volume
      await _systemControls.muteVolume();
      _volume.value = 0.0;
      _baseController?.setVolume(0.0);
    } else {
      // Restore volume (default to 50% if was 0)
      const restoreVolume = 0.5;
      await setVolume(restoreVolume);
    }
  }

  void toggleVolumeSlider() {
    _showVolumeSlider.value = !_showVolumeSlider.value;
    _showBrightnessSlider.value = false;
    _showSpeedSelector.value = false;
  }

  void toggleBrightnessSlider() {
    _showBrightnessSlider.value = !_showBrightnessSlider.value;
    _showVolumeSlider.value = false;
    _showSpeedSelector.value = false;
  }

  void toggleSpeedSelector() {
    _showSpeedSelector.value = !_showSpeedSelector.value;
    _showVolumeSlider.value = false;
    _showBrightnessSlider.value = false;
  }

  void hideAllSliders() {
    _showVolumeSlider.value = false;
    _showBrightnessSlider.value = false;
    _showSpeedSelector.value = false;
  }

  void toggleFullScreen() {
    _isFullScreen.value = !_isFullScreen.value;
    if (_isFullScreen.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void seekToPercentage(double percentage) {
    if (_baseController == null) return;
    final duration = _baseController!.duration;
    final position = Duration(
      milliseconds: (duration.inMilliseconds * percentage).round(),
    );
    seekTo(position);
  }

  Future<void> adjustBrightnessByGesture(double delta) async {
    final newBrightness = (_brightness.value + delta).clamp(0.0, 1.0);
    await setBrightness(newBrightness);
  }

  Future<void> adjustVolumeByGesture(double delta) async {
    final newVolume = (_volume.value + delta).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  void _hideSliderAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      _showBrightnessSlider.value = false;
      _showVolumeSlider.value = false;
    });
  }

  void seekByGesture(double delta) {
    if (_baseController == null) return;
    final currentPosition = _baseController!.position;
    final duration = _baseController!.duration;
    final newPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds + (delta * 1000)).round(),
    );

    if (newPosition.isNegative) {
      seekTo(Duration.zero);
    } else if (newPosition > duration) {
      seekTo(duration);
    } else {
      seekTo(newPosition);
    }
  }

  void retryInitialization(String videoPath) {
    _disposeControllers();
    initializePlayer(videoPath);
  }

  void _disposeControllers() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_videoPlayerListener);
    }
    _baseController?.removeListener(_videoPlayerListener);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _baseController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
    _baseController = null;
  }

  @override
  void onClose() {
    _onCloseAsync();
    super.onClose();
  }

  Future<void> _onCloseAsync() async {
    // Reset system UI when closing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Disable wakelock when closing video player
    _disableWakelock();

    // Dispose system controls
    await _systemControls.dispose();

    _controlsAnimationController.dispose();
    _disposeControllers();
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      appLog('Could not disable wakelock: $e', color: 'yellow');
    }
  }
}
