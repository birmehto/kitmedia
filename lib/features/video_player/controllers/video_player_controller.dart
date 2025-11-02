import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/utils/logger.dart';

class VideoPlayerController extends GetxController {
  // Media Kit player
  Player? _player;
  Player? get player => _player;

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
  final RxBool _isMuted = false.obs;

  // Media properties
  final RxDouble _volume = 100.0.obs; // Media Kit uses 0-100 scale
  final RxDouble _playbackSpeed = 1.0.obs;
  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;
  final RxDouble _aspectRatio = (16 / 9).obs;
  final RxString _videoResolution = ''.obs;

  // Advanced features
  final RxBool _isLandscape = false.obs;
  final RxBool _autoHideControls = true.obs;
  final RxInt _controlsHideDelay = 3.obs; // seconds
  final RxBool _rememberPosition = true.obs;
  final RxBool _autoPlay = true.obs;
  final RxBool _loopVideo = false.obs;

  // Gesture controls
  final RxBool _gesturesEnabled = true.obs;
  final RxDouble _seekSensitivity = 1.0.obs;
  final RxDouble _volumeSensitivity = 1.0.obs;
  final RxDouble _brightnessSensitivity = 1.0.obs;

  // Performance tracking
  final RxInt _bufferHealth = 0.obs;
  final RxString _playbackInfo = ''.obs;
  final RxBool _hardwareAcceleration = true.obs;

  // Timers and subscriptions
  Timer? _hideControlsTimer;
  Timer? _positionSaveTimer;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferingSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _completedSubscription;

  // Getters - Core State
  bool get isInitialized => _isInitialized.value;
  bool get isPlaying => _isPlaying.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isControlsVisible => _isControlsVisible.value;
  bool get isFullScreen => _isFullScreen.value;
  bool get isBuffering => _isBuffering.value;
  bool get isCompleted => _isCompleted.value;
  bool get isMuted => _isMuted.value;

  // Getters - Media Properties
  double get volume => _volume.value;
  double get playbackSpeed => _playbackSpeed.value;
  Duration get position => _position.value;
  Duration get duration => _duration.value;
  double get aspectRatio => _aspectRatio.value;
  String get videoResolution => _videoResolution.value;

  // Getters - Advanced Features
  bool get isLandscape => _isLandscape.value;
  bool get autoHideControls => _autoHideControls.value;
  int get controlsHideDelay => _controlsHideDelay.value;
  bool get rememberPosition => _rememberPosition.value;
  bool get autoPlay => _autoPlay.value;
  bool get loopVideo => _loopVideo.value;

  // Getters - Gesture Controls
  bool get gesturesEnabled => _gesturesEnabled.value;
  double get seekSensitivity => _seekSensitivity.value;
  double get volumeSensitivity => _volumeSensitivity.value;
  double get brightnessSensitivity => _brightnessSensitivity.value;

  // Getters - Performance
  int get bufferHealth => _bufferHealth.value;
  String get playbackInfo => _playbackInfo.value;
  bool get hardwareAcceleration => _hardwareAcceleration.value;

  // Progress as percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Remaining time
  Duration get remainingTime {
    return duration - position;
  }

  // Available speeds with more options
  final List<double> availableSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.5,
    3.0,
  ];

  // Supported video formats
  static const List<String> supportedFormats = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
    'ogv',
  ];

  @override
  void onInit() {
    super.onInit();
    _enableWakelock();
    _setupOrientationListener();
  }

  void _setupOrientationListener() {
    // Listen for orientation changes
    ever(_isLandscape, (isLandscape) {
      _handleOrientationChange(isLandscape);
    });
  }

  void _handleOrientationChange(bool isLandscape) {
    if (isLandscape) {
      _enterLandscapeMode();
    } else {
      _exitLandscapeMode();
    }
  }

  void _enterLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> initializePlayer(String videoPath) async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';
      _isCompleted.value = false;

      final file = File(videoPath);
      if (!file.existsSync()) {
        throw Exception('Video file not found: $videoPath');
      }

      // Validate file format
      if (!_isValidVideoFormat(videoPath)) {
        throw Exception(
          'Unsupported video format: ${_getFileExtension(videoPath)}',
        );
      }

      // Create Media Kit player with configuration
      _player = Player(
        configuration: PlayerConfiguration(title: _getFileName(videoPath)),
      );

      // Setup stream listeners
      _setupStreamListeners();

      // Load saved position if enabled
      Duration? savedPosition;
      if (_rememberPosition.value) {
        savedPosition = await _loadSavedPosition(videoPath);
      }

      // Open the media file
      await _player!.open(Media(file.path));

      // Restore saved position
      if (savedPosition != null && savedPosition > Duration.zero) {
        await _player!.seek(savedPosition);
      }

      // Auto-play if enabled
      if (_autoPlay.value) {
        await _player!.play();
      }

      _isInitialized.value = true;
      _isLoading.value = false;

      if (_autoHideControls.value) {
        _startHideControlsTimer();
      }

      // Start position saving timer
      _startPositionSaveTimer(videoPath);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = _getDetailedErrorMessage(e.toString(), videoPath);
      _isLoading.value = false;
      _dispose();
    }
  }

  void _setupStreamListeners() {
    if (_player == null) return;

    // Playing state
    _playingSubscription = _player!.stream.playing.listen((playing) {
      _isPlaying.value = playing;
      _updatePlaybackInfo();
    });

    // Position
    _positionSubscription = _player!.stream.position.listen((position) {
      _position.value = position;

      // Check if video completed
      if (_duration.value > Duration.zero &&
          position >= _duration.value - const Duration(milliseconds: 500)) {
        _handleVideoCompleted();
      }
    });

    // Duration
    _durationSubscription = _player!.stream.duration.listen((duration) {
      _duration.value = duration;
      _updatePlaybackInfo();
    });

    // Buffering state
    _bufferingSubscription = _player!.stream.buffering.listen((buffering) {
      _isBuffering.value = buffering;
      _updateBufferHealth();
    });

    // Completed state
    _completedSubscription = _player!.stream.completed.listen((completed) {
      if (completed) {
        _handleVideoCompleted();
      }
    });

    // Error handling
    _errorSubscription = _player!.stream.error.listen((error) {
      _hasError.value = true;
      _errorMessage.value = _getDetailedErrorMessage(error, '');
      _isInitialized.value = false;
    });

    // Video track info for resolution
    _player!.stream.tracks.listen((tracks) {
      _updateVideoInfo(tracks);
    });
  }

  void _handleVideoCompleted() {
    _isCompleted.value = true;

    if (_loopVideo.value) {
      // Restart video if looping is enabled
      seekTo(Duration.zero);
      play();
    } else {
      // Show controls when video completes
      _showControls();
    }
  }

  void _updateVideoInfo(Tracks tracks) {
    if (tracks.video.isNotEmpty) {
      final videoTrack = tracks.video.first;
      if (videoTrack.w != null && videoTrack.h != null) {
        _videoResolution.value = '${videoTrack.w}×${videoTrack.h}';
        _aspectRatio.value = videoTrack.w! / videoTrack.h!;
      }
    }
  }

  void _updatePlaybackInfo() {
    if (_duration.value > Duration.zero) {
      final progressPercent = (progress * 100).toStringAsFixed(1);
      final speedText = _playbackSpeed.value == 1.0
          ? ''
          : ' (${_playbackSpeed.value}x)';
      _playbackInfo.value = '$progressPercent%$speedText';
    }
  }

  void _updateBufferHealth() {
    // Simulate buffer health calculation
    _bufferHealth.value = _isBuffering.value
        ? max(0, _bufferHealth.value - 10)
        : min(100, _bufferHealth.value + 5);
  }

  bool _isValidVideoFormat(String path) {
    final extension = _getFileExtension(path);
    return supportedFormats.contains(extension);
  }

  String _getFileExtension(String path) {
    return path.toLowerCase().split('.').last;
  }

  String _getFileName(String path) {
    return path.split('/').last.split('.').first;
  }

  String _getDetailedErrorMessage(String error, String videoPath) {
    final extension = videoPath.isNotEmpty ? _getFileExtension(videoPath) : '';

    if (error.contains('Unsupported video format')) {
      return 'Video format (.$extension) is not supported. Try converting to MP4.';
    }

    if (error.contains('Source error') ||
        error.contains('Failed to open') ||
        error.contains('Could not open')) {
      return 'Cannot play this video${extension.isNotEmpty ? ' (.$extension)' : ''}. The file may be corrupted or use an unsupported codec.';
    }

    if (error.contains('Video file not found')) {
      return 'Video file not found. The file may have been moved or deleted.';
    }

    if (error.contains('permission') || error.contains('Permission')) {
      return 'Permission denied. Please grant storage access to play videos.';
    }

    if (error.contains('Network') || error.contains('network')) {
      return 'Network error occurred while loading the video.';
    }

    return error.isNotEmpty
        ? error
        : 'An unexpected error occurred while trying to play the video.';
  }

  // Enhanced playback controls
  Future<void> play() async {
    await _player?.play();
    if (_autoHideControls.value) {
      _startHideControlsTimer();
    }
  }

  Future<void> pause() async {
    await _player?.pause();
    _showControls();
  }

  void togglePlayPause() {
    if (_player == null) return;

    if (_isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(Duration position) {
    final clampedPosition = Duration(
      milliseconds: position.inMilliseconds.clamp(
        0,
        _duration.value.inMilliseconds,
      ),
    );
    _player?.seek(clampedPosition);
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

  void skipToBeginning() {
    seekTo(Duration.zero);
  }

  void skipToEnd() {
    seekTo(_duration.value);
  }

  // Enhanced volume controls
  void setVolume(double value) {
    final clampedValue = value.clamp(0.0, 100.0);
    _volume.value = clampedValue;
    _isMuted.value = clampedValue == 0.0;
    _player?.setVolume(clampedValue);
  }

  void increaseVolume([double amount = 10.0]) {
    setVolume(_volume.value + amount);
  }

  void decreaseVolume([double amount = 10.0]) {
    setVolume(_volume.value - amount);
  }

  void toggleMute() {
    if (_isMuted.value) {
      setVolume(50.0); // Restore to 50% if was muted
    } else {
      setVolume(0.0); // Mute
    }
  }

  // Enhanced speed controls
  void setPlaybackSpeed(double speed) {
    final clampedSpeed = speed.clamp(0.25, 3.0);
    _playbackSpeed.value = clampedSpeed;
    _player?.setRate(clampedSpeed);
    _updatePlaybackInfo();
  }

  void increaseSpeed() {
    final currentIndex = availableSpeeds.indexOf(_playbackSpeed.value);
    if (currentIndex < availableSpeeds.length - 1) {
      setPlaybackSpeed(availableSpeeds[currentIndex + 1]);
    }
  }

  void decreaseSpeed() {
    final currentIndex = availableSpeeds.indexOf(_playbackSpeed.value);
    if (currentIndex > 0) {
      setPlaybackSpeed(availableSpeeds[currentIndex - 1]);
    }
  }

  void resetSpeed() {
    setPlaybackSpeed(1.0);
  }

  // Enhanced controls management
  void showControls() {
    appLog('showControls called');
    _isControlsVisible.value = true;
    if (_autoHideControls.value) {
      _startHideControlsTimer();
    }
  }

  void hideControls() {
    appLog('hideControls called');
    _isControlsVisible.value = false;
    _cancelHideControlsTimer();
  }

  void toggleControls() {
    appLog(
      'toggleControls called - current state: ${_isControlsVisible.value}',
    );
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
    appLog(
      '_startHideControlsTimer called - autoHide: ${_autoHideControls.value}, isPlaying: ${_isPlaying.value}',
    );
    if (_autoHideControls.value && _isPlaying.value) {
      _hideControlsTimer = Timer(
        Duration(seconds: _controlsHideDelay.value),
        () {
          appLog('Timer fired - hiding controls');
          if (_isPlaying.value) {
            _isControlsVisible.value = false;
          }
        },
      );
    }
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  // Enhanced fullscreen controls
  void toggleFullScreen() {
    _isFullScreen.value = !_isFullScreen.value;
    _isLandscape.value = _isFullScreen.value;

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

  void enterLandscapeMode() {
    if (!_isLandscape.value) {
      _isLandscape.value = true;
      _isFullScreen.value = true;
      _enterFullScreenMode();
    }
  }

  void exitLandscapeMode() {
    if (_isLandscape.value) {
      _isLandscape.value = false;
      _isFullScreen.value = false;
      _exitFullScreenMode();
    }
  }

  // Settings management
  void setAutoHideControls(bool enabled) {
    _autoHideControls.value = enabled;
    if (!enabled) {
      _cancelHideControlsTimer();
    } else if (_isPlaying.value) {
      _startHideControlsTimer();
    }
  }

  void setControlsHideDelay(int seconds) {
    _controlsHideDelay.value = seconds.clamp(1, 10);
  }

  void setRememberPosition(bool enabled) {
    _rememberPosition.value = enabled;
  }

  void setAutoPlay(bool enabled) {
    _autoPlay.value = enabled;
  }

  void setLoopVideo(bool enabled) {
    _loopVideo.value = enabled;
  }

  void setGesturesEnabled(bool enabled) {
    _gesturesEnabled.value = enabled;
  }

  void setSeekSensitivity(double sensitivity) {
    _seekSensitivity.value = sensitivity.clamp(0.1, 3.0);
  }

  void setVolumeSensitivity(double sensitivity) {
    _volumeSensitivity.value = sensitivity.clamp(0.1, 3.0);
  }

  void setBrightnessSensitivity(double sensitivity) {
    _brightnessSensitivity.value = sensitivity.clamp(0.1, 3.0);
  }

  // Position saving/loading
  Future<Duration?> _loadSavedPosition(String videoPath) async {
    try {
      // This would typically use SharedPreferences or a database
      // For now, return null (no saved position)
      return null;
    } catch (e) {
      return null;
    }
  }

  void _startPositionSaveTimer(String videoPath) {
    if (!_rememberPosition.value) return;

    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _saveCurrentPosition(videoPath);
    });
  }

  Future<void> _saveCurrentPosition(String videoPath) async {
    if (_position.value > Duration.zero && _duration.value > Duration.zero) {
      try {
        // This would typically save to SharedPreferences or a database
        // Implementation depends on your storage preference
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Gesture handling helpers
  void handleSeekGesture(double delta) {
    if (!_gesturesEnabled.value) return;

    final seekAmount = (delta * _seekSensitivity.value * 30)
        .round(); // Max 30 seconds
    if (seekAmount > 0) {
      seekForward(seekAmount);
    } else {
      seekBackward(seekAmount.abs());
    }
  }

  void handleVolumeGesture(double delta) {
    if (!_gesturesEnabled.value) return;

    final volumeChange =
        delta * _volumeSensitivity.value * 20; // Max 20% change
    setVolume(_volume.value + volumeChange);
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
    // Cancel timers
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;

    // Cancel subscriptions
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _errorSubscription?.cancel();
    _completedSubscription?.cancel();

    // Reset subscriptions
    _playingSubscription = null;
    _positionSubscription = null;
    _durationSubscription = null;
    _bufferingSubscription = null;
    _errorSubscription = null;
    _completedSubscription = null;

    // Dispose player
    _player?.dispose();
    _player = null;

    // Reset state
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
