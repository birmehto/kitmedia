import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../../core/services/cross_platform_video_player.dart';
import '../../../core/utils/logger.dart';

class VideoPlayerController extends GetxController
    with GetTickerProviderStateMixin {
  BaseVideoPlayerController? _baseController;
  vp.VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  final RxBool _isControlsVisible = true.obs;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isFullScreen = false.obs;
  final RxDouble _brightness = 0.5.obs;
  final RxDouble _volume = 1.0.obs;
  final RxDouble _playbackSpeed = 1.0.obs;
  final RxBool _isBuffering = false.obs;
  final RxBool _showVolumeSlider = false.obs;
  final RxBool _showBrightnessSlider = false.obs;
  final RxBool _showSpeedSelector = false.obs;
  final RxString _videoQuality = 'Auto'.obs;

  // Getters
  BaseVideoPlayerController? get baseController => _baseController;
  vp.VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ChewieController? get chewieController => _chewieController;
  Animation<double> get controlsAnimation => _controlsAnimation;
  bool get isControlsVisible => _isControlsVisible.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasError => _errorMessage.value.isNotEmpty;
  bool get isFullScreen => _isFullScreen.value;
  double get brightness => _brightness.value;
  double get volume => _volume.value;
  double get playbackSpeed => _playbackSpeed.value;
  bool get isBuffering => _isBuffering.value;
  bool get showVolumeSlider => _showVolumeSlider.value;
  bool get showBrightnessSlider => _showBrightnessSlider.value;
  bool get showSpeedSelector => _showSpeedSelector.value;
  String get videoQuality => _videoQuality.value;

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

  // Available video qualities
  final List<String> videoQualities = [
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
    // Initialize cross-platform video player
    CrossPlatformVideoPlayer.initialize();
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
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _isInitialized.value = false;

      final file = File(videoPath);
      if (!file.existsSync()) {
        throw Exception('Video file not found: $videoPath');
      }

      appLog('Loading video file: $videoPath');

      // Create appropriate controller based on platform
      _baseController = VideoPlayerControllerFactory.create();
      await _baseController!.initialize(videoPath);

      // For mobile platforms, we still use Chewie for UI
      if (CrossPlatformVideoPlayer.isMobile &&
          _baseController is MobileVideoPlayerController) {
        final mobileController = _baseController as MobileVideoPlayerController;
        _videoPlayerController = mobileController.videoPlayerController;

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          showControls: false, // We'll use custom controls
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          allowFullScreen: false, // We'll handle fullscreen manually
          allowPlaybackSpeedChanging: false, // We'll handle this manually
          errorBuilder: (context, errorMessage) {
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
          },
        );

        // Listen to video player state changes
        _videoPlayerController!.addListener(_videoPlayerListener);
      }

      _isInitialized.value = true;
      _isLoading.value = false;
      hideControlsAfterDelay();
    } catch (e) {
      appLog('Video player error: $e');
      _isLoading.value = false;
      _errorMessage.value = e.toString();
      _isInitialized.value = false;
    }
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

  void setBrightness(double value) {
    _brightness.value = value.clamp(0.0, 1.0);
    // Apply brightness to screen (this would need platform-specific implementation)
  }

  void setVolume(double value) {
    _volume.value = value.clamp(0.0, 1.0);
    _baseController?.setVolume(_volume.value);
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed.value = speed;
    _baseController?.setPlaybackSpeed(speed);
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

  void adjustBrightnessByGesture(double delta) {
    final newBrightness = (_brightness.value + delta).clamp(0.0, 1.0);
    setBrightness(newBrightness);
  }

  void adjustVolumeByGesture(double delta) {
    final newVolume = (_volume.value + delta).clamp(0.0, 1.0);
    setVolume(newVolume);
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

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
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
    // Reset system UI when closing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controlsAnimationController.dispose();
    _disposeControllers();
    super.onClose();
  }
}
