import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/video_player_controller.dart';
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

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(VideoPlayerController());

    // Initialize player after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializePlayer(widget.videoPath);
    });
  }

  @override
  void dispose() {
    Get.delete<VideoPlayerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _controller.isFullScreen
              ? SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: VideoPlayerWidget(
              videoTitle: widget.videoTitle,
              videoPath: widget.videoPath,
            ),
          ),
        );
      }),
    );
  }
}
