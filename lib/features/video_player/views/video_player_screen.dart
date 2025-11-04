import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/video_player_controller.dart';
import '../widgets/video_error_widget.dart';
import '../widgets/video_player_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });

  final String videoPath;
  final String videoTitle;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late final VideoPlayerController _controller;
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use a unique tag based on the video path
    _controller = Get.put(VideoPlayerController(), tag: widget.videoPath);
    _controller.screenshotKey = _screenshotKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.initialize(widget.videoPath);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Get.isRegistered<VideoPlayerController>(tag: widget.videoPath)) {
      Get.delete<VideoPlayerController>(tag: widget.videoPath, force: true);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        // Optionally resume playback
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Handle error state
        if (_controller.hasError.value) {
          return VideoErrorWidget(
            error: _controller.errorMessage.value,
            onRetry: () => _controller.retry(widget.videoPath),
          );
        }

        final fullScreen = _controller.isFullScreen.value;

        final overlayStyle = SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: fullScreen
              ? Colors.transparent
              : Colors.black,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: SafeArea(
            top: false,
            bottom: false,
            child: RepaintBoundary(
              key: _screenshotKey,
              child: VideoPlayerWidget(
                videoTitle: widget.videoTitle,
                videoPath: widget.videoPath,
              ),
            ),
          ),
        );
      }),
    );
  }
}
