import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerController extends GetxController {
  // Better Player controller
  BetterPlayerController? _betterPlayerController;
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  // Core state variables
  final RxBool _isInitialized = false.obs;
  final RxBool _isPlaying = false.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isControlsVisible = true.obs;
  final RxBool _isFullScreen = false.obs;
  final RxBool _isBuffering = false.obs;
  final RxBool _isCompleted = false.obs;

  // Media properties
  final RxDouble _volume = 1.0.obs;
  final RxDouble _playbackSpeed = 1.0.obs;
  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;
  final RxDouble _aspectRatio = (16 / 9).obs;
  final RxString _videoResolution = ''.obs;

  // Settings
  final RxBool _autoHideControls = true.obs;
  final RxBool _rememberPosition = true.obs;
  final RxBool _loopVideo = false.obs;
  final RxBool _gesturesEnabled = true.obs;

  // Timers
  Timer? _hideControlsTimer;
  Timer? _positionUpdateTimer;
  String? _currentVideoPath;

  // Getters
  bool get isInitialized => _isInitialized.value;
  bool get isPlaying => _isPlaying.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isControlsVisible => _isControlsVisible.value;
  bool get isFullScreen => _isFullScreen.value;
  bool get isBuffering => _isBuffering.value;
  bool get isCompleted => _isCompleted.value;
  double get volume => _volume.value;
  double get playbackSpeed => _playbackSpeed.value;
  Duration get position => _position.value;
  Duration get duration => _duration.value;
  double get aspectRatio => _aspectRatio.value;
  String get videoResolution => _videoResolution.value;
  bool get autoHideControls => _autoHideControls.value;
  bool get rememberPosition => _rememberPosition.value;
  bool get loopVideo => _loopVideo.value;
  bool get gesturesEnabled => _gesturesEnabled.value;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  final List<double> availableSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  void onInit() {
    super.onInit();
    _enableWakelock();
  }

  Future<void> initializePlayer(String videoPath) async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';
      _isCompleted.value = false;
      _currentVideoPath = videoPath;

      final file = File(videoPath);
      if (!file.existsSync()) {
        throw Exception('Video file not found: $videoPath');
      }

      // Load saved position if enabled
      Duration? savedPosition;
      if (_rememberPosition.value) {
        savedPosition = await _loadSavedPosition(videoPath);
      }

      // Create Better Player configuration
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: _loopVideo.value,
        startAt: savedPosition,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false, // We'll use custom controls
          enableProgressText: false,
          enableProgressBar: false,
          enablePlayPause: false,
          enableMute: false,
          enableFullscreen: false,
          enableSkips: false,
          enableAudioTracks: false,
          enableSubtitles: false,
          enableQualities: false,
          enablePlaybackSpeed: false,
        ),
        eventListener: _onBetterPlayerEvent,
      );

      // Create data source
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        file.path,
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: true,
        ),
      );

      // Initialize Better Player
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
      );
      await _betterPlayerController!.setupDataSource(betterPlayerDataSource);

      _isInitialized.value = true;
      _isLoading.value = false;

      // Start position update timer
      _startPositionUpdateTimer();

      if (_autoHideControls.value) {
        _startHideControlsTimer();
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = _getDetailedErrorMessage(e.toString(), videoPath);
      _isLoading.value = false;
      _dispose();
    }
  }

  void _onBetterPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _updateVideoInfo();
        break;
      case BetterPlayerEventType.play:
        _isPlaying.value = true;
        if (_autoHideControls.value) {
          _startHideControlsTimer();
        }
        break;
      case BetterPlayerEventType.pause:
        _isPlaying.value = false;
        _showControls();
        break;
      case BetterPlayerEventType.seekTo:
        // Handle seek
        break;
      case BetterPlayerEventType.finished:
        _isCompleted.value = true;
        _showControls();
        break;
      case BetterPlayerEventType.bufferingStart:
        _isBuffering.value = true;
        break;
      case BetterPlayerEventType.bufferingEnd:
        _isBuffering.value = false;
        break;
      case BetterPlayerEventType.exception:
        _hasError.value = true;
        _errorMessage.value = 'Playback error occurred';
        break;
      default:
        break;
    }
  }

  void _updateVideoInfo() {
    if (_betterPlayerController?.videoPlayerController?.value != null) {
      final videoValue = _betterPlayerController!.videoPlayerController!.value;
      _duration.value = videoValue.duration ?? Duration.zero;
      _aspectRatio.value = videoValue.aspectRatio;

      // Get video resolution
      final size = videoValue.size;
      if (size != null &&
          size != Size.zero &&
          size.width > 0 &&
          size.height > 0) {
        _videoResolution.value = '${size.width.toInt()}×${size.height.toInt()}';
      }
    }
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (_betterPlayerController?.videoPlayerController?.value != null) {
        _position.value =
            _betterPlayerController!.videoPlayerController!.value.position;

        // Save position periodically
        if (_rememberPosition.value && _currentVideoPath != null) {
          _saveCurrentPosition(_currentVideoPath!);
        }
      }
    });
  }

  String _getDetailedErrorMessage(String error, String videoPath) {
    if (error.contains('Video file not found')) {
      return 'Video file not found. The file may have been moved or deleted.';
    }
    if (error.contains('permission') || error.contains('Permission')) {
      return 'Permission denied. Please grant storage access to play videos.';
    }
    if (error.contains('format') || error.contains('codec')) {
      return 'This video format is not supported on your device.';
    }
    if (error.contains('Playback error')) {
      return 'An error occurred during video playback. The file may be corrupted or incompatible.';
    }
    return error.isNotEmpty
        ? error
        : 'An unexpected error occurred while trying to play the video.';
  }

  // Playback controls
  Future<void> play() async {
    await _betterPlayerController?.play();
  }

  Future<void> pause() async {
    await _betterPlayerController?.pause();
  }

  void togglePlayPause() {
    if (_isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(Duration position) {
    _betterPlayerController?.seekTo(position);
  }

  void seekToPercentage(double percentage) {
    final position = Duration(
      milliseconds:
          (_duration.value.inMilliseconds * percentage.clamp(0.0, 1.0)).round(),
    );
    seekTo(position);
  }

  void seekBackward([int seconds = 10]) {
    final newPosition = _position.value - Duration(seconds: seconds);
    seekTo(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void seekForward([int seconds = 10]) {
    final newPosition = _position.value + Duration(seconds: seconds);
    seekTo(newPosition > _duration.value ? _duration.value : newPosition);
  }

  // Volume controls
  void setVolume(double value) {
    final clampedValue = value.clamp(0.0, 1.0);
    _volume.value = clampedValue;
    _betterPlayerController?.setVolume(clampedValue);
  }

  void toggleMute() {
    if (_volume.value > 0) {
      setVolume(0.0);
    } else {
      setVolume(1.0);
    }
  }

  // Speed controls
  void setPlaybackSpeed(double speed) {
    _playbackSpeed.value = speed;
    _betterPlayerController?.setSpeed(speed);
  }

  // Controls management
  void showControls() {
    _isControlsVisible.value = true;
    if (_autoHideControls.value && _isPlaying.value) {
      _startHideControlsTimer();
    }
  }

  void hideControls() {
    _isControlsVisible.value = false;
    _cancelHideControlsTimer();
  }

  void toggleControls() {
    if (_isControlsVisible.value) {
      hideControls();
    } else {
      showControls();
    }
  }

  void _showControls() {
    showControls();
  }

  void _startHideControlsTimer() {
    _cancelHideControlsTimer();
    if (_autoHideControls.value && _isPlaying.value) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (_isPlaying.value) {
          _isControlsVisible.value = false;
        }
      });
    }
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  // Fullscreen controls
  void toggleFullScreen() {
    _isFullScreen.value = !_isFullScreen.value;

    if (_isFullScreen.value) {
      _enterFullScreenMode();
    } else {
      _exitFullScreenMode();
    }
  }

  void _enterFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // Settings
  void setAutoHideControls(bool enabled) {
    _autoHideControls.value = enabled;
    if (!enabled) {
      _cancelHideControlsTimer();
    } else if (_isPlaying.value) {
      _startHideControlsTimer();
    }
  }

  void setRememberPosition(bool enabled) {
    _rememberPosition.value = enabled;
  }

  void setLoopVideo(bool enabled) {
    _loopVideo.value = enabled;
    // Update Better Player configuration if needed
  }

  void setGesturesEnabled(bool enabled) {
    _gesturesEnabled.value = enabled;
  }

  // Position saving/loading
  Future<Duration?> _loadSavedPosition(String videoPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMs = prefs.getInt('video_position_${videoPath.hashCode}');
      if (savedMs != null && savedMs > 0) {
        return Duration(milliseconds: savedMs);
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }

  Future<void> _saveCurrentPosition(String videoPath) async {
    if (_position.value > Duration.zero && _duration.value > Duration.zero) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          'video_position_${videoPath.hashCode}',
          _position.value.inMilliseconds,
        );
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Utility methods
  void retryInitialization(String videoPath) {
    _dispose();
    initializePlayer(videoPath);
  }

  void restart() {
    seekTo(Duration.zero);
    play();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      // Handle error silently
    }
  }

  void _dispose() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = null;

    _betterPlayerController?.dispose();
    _betterPlayerController = null;

    _isInitialized.value = false;
    _isCompleted.value = false;
  }

  @override
  void onClose() {
    _cancelHideControlsTimer();

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _disableWakelock();
    _dispose();
    super.onClose();
  }
}
