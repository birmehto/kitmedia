import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

/// Cross-platform video player service that handles mobile platforms only
class CrossPlatformVideoPlayer {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Initialize video player (no initialization needed for mobile)
  static void initialize() {
    // No initialization needed for mobile platforms
  }
}

/// Abstract base class for video player controllers
abstract class BaseVideoPlayerController {
  bool get isInitialized;
  bool get isPlaying;
  Duration get position;
  Duration get duration;
  double get aspectRatio;

  Future<void> initialize(String videoPath);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double speed);
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
  void dispose();
}

/// Mobile video player controller using video_player package
class MobileVideoPlayerController extends BaseVideoPlayerController {
  vp.VideoPlayerController? _controller;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  bool get isPlaying => _controller?.value.isPlaying ?? false;

  @override
  Duration get position => _controller?.value.position ?? Duration.zero;

  @override
  Duration get duration => _controller?.value.duration ?? Duration.zero;

  @override
  double get aspectRatio => _controller?.value.aspectRatio ?? 16 / 9;

  vp.VideoPlayerController? get videoPlayerController => _controller;

  @override
  Future<void> initialize(String videoPath) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      throw Exception('Video file not found: $videoPath');
    }

    _controller = vp.VideoPlayerController.file(file);
    await _controller!.initialize();
  }

  @override
  Future<void> play() async {
    await _controller?.play();
  }

  @override
  Future<void> pause() async {
    await _controller?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _controller?.setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _controller?.setPlaybackSpeed(speed);
  }

  @override
  void addListener(VoidCallback listener) {
    _controller?.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller?.removeListener(listener);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Factory to create appropriate video player controller
class VideoPlayerControllerFactory {
  static BaseVideoPlayerController create() {
    return MobileVideoPlayerController();
  }
}
