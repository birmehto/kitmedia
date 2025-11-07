import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';

class VideoPlayerController extends GetxController {
  BetterPlayerController? _controller;
  BetterPlayerController? get player => _controller;

  // Reactive state
  final isInitialized = false.obs;
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isControlsVisible = true.obs;
  final isFullScreen = false.obs;
  final isBuffering = false.obs;
  final isCompleted = false.obs;

  // Media
  final volume = 1.0.obs;
  final speed = 1.0.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final aspectRatio = (16 / 9).obs;
  final resolution = ''.obs;
  final brightness = 0.5.obs;

  // Settings
  final autoHide = true.obs;
  final rememberPosition = true.obs;
  final loop = false.obs;
  final gesturesEnabled = true.obs;
  final pipEnabled = false.obs;

  // Playlist
  final playlist = <String>[].obs;
  final currentIndex = 0.obs;

  // Screenshot
  GlobalKey? screenshotKey;

  Timer? _hideTimer, _posTimer;
  String? _path;

  List<double> get speeds => [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

  double get progress => duration.value.inMilliseconds == 0
      ? 0
      : position.value.inMilliseconds / duration.value.inMilliseconds;

  @override
  void onInit() {
    super.onInit();
    _enableWakelock();
    _initializeBrightness();
    _initializeVolume();
  }

  Future<void> _initializeBrightness() async {
    try {
      final currentBrightness = await ScreenBrightness().application;
      brightness.value = currentBrightness;
    } catch (e) {
      brightness.value = 0.5; // Default brightness
    }
  }

  Future<void> _initializeVolume() async {
    try {
      final currentVolume = await VolumeController.instance.getVolume();
      volume.value = currentVolume;
    } catch (e) {
      volume.value = 1.0; // Default volume
    }
  }

  Future<void> initialize(String path) async {
    try {
      _resetState();
      isLoading.value = true;
      _path = path;

      // ignore: only_throw_errors
      if (!File(path).existsSync()) throw 'Video file not found: $path';

      final startAt = rememberPosition.value
          ? await _loadSavedPosition(path)
          : null;

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: aspectRatio.value,
          fit: BoxFit.contain,
          autoPlay: true,
          looping: loop.value,
          startAt: startAt,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
          ),
          eventListener: _onEvent,
        ),
      );

      await _controller!.setupDataSource(
        BetterPlayerDataSource(BetterPlayerDataSourceType.file, path),
      );

      isInitialized.value = true;
      isLoading.value = false;

      _startTimers();
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    }
  }

  void _onEvent(BetterPlayerEvent e) {
    switch (e.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _updateInfo();
        break;
      case BetterPlayerEventType.play:
        isPlaying.value = true;
        _autoHideControls();
        break;
      case BetterPlayerEventType.pause:
        isPlaying.value = false;
        showControls();
        break;
      case BetterPlayerEventType.finished:
        isCompleted.value = true;
        showControls();
        break;
      case BetterPlayerEventType.bufferingStart:
        isBuffering.value = true;
        break;
      case BetterPlayerEventType.bufferingEnd:
        isBuffering.value = false;
        break;
      case BetterPlayerEventType.exception:
        _setError('Playback error occurred');
        break;
      default:
        break;
    }
  }

  void _updateInfo() {
    final v = _controller?.videoPlayerController?.value;
    if (v == null) return;
    duration.value = v.duration ?? Duration.zero;
    aspectRatio.value = v.aspectRatio;
    final s = v.size;
    if (s != null && s.width > 0 && s.height > 0) {
      resolution.value = '${s.width.toInt()}×${s.height.toInt()}';
    }
  }

  void _startTimers() {
    _posTimer?.cancel();
    _posTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final v = _controller?.videoPlayerController?.value;
      if (v == null) return;
      position.value = v.position;
      if (rememberPosition.value && _path != null) await _savePosition(_path!);
    });
    _autoHideControls();
  }

  void _autoHideControls() {
    _hideTimer?.cancel();
    if (!autoHide.value || !isPlaying.value) return;
    _hideTimer = Timer(
      const Duration(seconds: 3),
      () => isControlsVisible.value = false,
    );
  }

  // --- Playback ---
  Future<void> play() => _controller?.play() ?? Future.value();
  Future<void> pause() => _controller?.pause() ?? Future.value();
  void togglePlay() => isPlaying.value ? pause() : play();

  void seek(Duration d) => _controller?.seekTo(d);
  void seekPercent(double p) => seek(
    Duration(
      milliseconds: (duration.value.inMilliseconds * p.clamp(0, 1)).round(),
    ),
  );
  void seekForward([int s = 10]) {
    final newPosition = position.value + Duration(seconds: s);
    final safePosition = newPosition > duration.value
        ? duration.value
        : newPosition;
    seek(safePosition);
  }

  void seekBackward([int s = 10]) {
    final newPosition = position.value - Duration(seconds: s);
    seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  // --- Controls ---
  void showControls() {
    isControlsVisible.value = true;
    _autoHideControls();
  }

  void toggleControls() => isControlsVisible.toggle();

  // --- Volume / Speed ---
  void setVolume(double v) {
    volume.value = v.clamp(0, 1);
    _controller?.setVolume(volume.value);
    VolumeController.instance.setVolume(volume.value);
  }

  void toggleMute() => setVolume(volume.value > 0 ? 0 : 1);

  void setSpeed(double s) {
    speed.value = s;
    _controller?.setSpeed(s);
  }

  // --- Brightness ---
  Future<void> setBrightness(double b) async {
    try {
      brightness.value = b.clamp(0, 1);
      await ScreenBrightness().setApplicationScreenBrightness(brightness.value);
    } catch (e) {
      // Handle brightness setting error
    }
  }

  // --- Fullscreen ---
  void toggleFullscreen() {
    isFullScreen.toggle();
    if (isFullScreen.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _resetSystemUi();
    }
    // Show controls briefly when toggling fullscreen
    showControls();
  }

  void enterFullscreen() {
    if (!isFullScreen.value) {
      toggleFullscreen();
    }
  }

  void exitFullscreen() {
    if (isFullScreen.value) {
      toggleFullscreen();
    }
  }

  // --- Preferences ---
  void setAutoHide(bool v) => autoHide.value = v;
  void setRememberPosition(bool v) => rememberPosition.value = v;
  void setLoop(bool v) {
    loop.value = v;
    if (_controller != null) {
      _controller!.setLooping(v);
    }
  }

  void setGesturesEnabled(bool v) => gesturesEnabled.value = v;
  void setPipEnabled(bool v) => pipEnabled.value = v;

  // --- Playlist ---
  void setPlaylist(List<String> videos, {int startIndex = 0}) {
    playlist.value = videos;
    currentIndex.value = startIndex.clamp(0, videos.length - 1);
  }

  void nextVideo() {
    if (playlist.isNotEmpty && currentIndex.value < playlist.length - 1) {
      currentIndex.value++;
      final nextPath = playlist[currentIndex.value];
      initialize(nextPath);
    }
  }

  void previousVideo() {
    if (playlist.isNotEmpty && currentIndex.value > 0) {
      currentIndex.value--;
      final prevPath = playlist[currentIndex.value];
      initialize(prevPath);
    }
  }

  // --- Screenshot ---
  Future<void> takeScreenshot() async {
    try {
      if (screenshotKey?.currentContext == null) return;

      final RenderRepaintBoundary boundary =
          screenshotKey!.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        await _saveScreenshot(pngBytes);

        appLog('Video screenshot saved to gallery');
      }
    } catch (e) {
      appLog('Could not save screenshot: ${e.toString()}');
    }
  }

  Future<void> _saveScreenshot(Uint8List bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory('${directory.path}/screenshots');

      if (!screenshotsDir.existsSync()) {
        await screenshotsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${screenshotsDir.path}/screenshot_$timestamp.png');
      await file.writeAsBytes(bytes);
    } catch (e) {
      rethrow;
    }
  }

  // --- Position save/load ---
  Future<void> _savePosition(String path) async {
    try {
      if (position.value > Duration.zero) {
        await StorageService.to.saveCacheData(
          'video_position_${path.hashCode}',
          position.value.inMilliseconds,
          const Duration(days: 30), // Cache for 30 days
        );
      }
    } catch (e) {
      appLog('Error=> ${e.toString()}');
    }
  }

  Future<Duration?> _loadSavedPosition(String path) async {
    try {
      final ms = StorageService.to.getCacheData<int>(
        'video_position_${path.hashCode}',
      );
      return ms != null ? Duration(milliseconds: ms) : null;
    } catch (_) {
      return null;
    }
  }

  // --- Utility ---
  void retry(String path) {
    disposePlayer();
    initialize(path);
  }

  void restart() {
    seek(Duration.zero);
    play();
  }

  String _getErrorMessage(String e) {
    if (e.contains('not found')) return 'Video file not found.';
    if (e.contains('permission')) {
      return 'Permission denied. Enable storage access.';
    }
    if (e.contains('format') || e.contains('codec')) {
      return 'Unsupported video format.';
    }
    return 'Playback error: $e';
  }

  void _setError(String msg) {
    hasError.value = true;
    errorMessage.value = msg;
    isLoading.value = false;
    disposePlayer();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      appLog('Error=> ${e.toString()}');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      appLog('Error=> ${e.toString()}');
    }
  }

  void _resetSystemUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _resetState() {
    isInitialized(false);
    hasError(false);
    errorMessage('');
    isCompleted(false);
  }

  void disposePlayer() {
    _posTimer?.cancel();
    _hideTimer?.cancel();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void onClose() {
    _resetSystemUi();
    _disableWakelock();
    disposePlayer();
    super.onClose();
  }
}
