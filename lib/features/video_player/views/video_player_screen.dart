import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_player_controller.dart';
import '../widgets/custom_video_player.dart';
import '../widgets/video_controls_overlay.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });

  final String videoPath;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(VideoPlayerController());

    return _VideoPlayerWidget(videoPath: videoPath, videoTitle: videoTitle);
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.videoPath, required this.videoTitle});

  final String videoPath;
  final String videoTitle;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VideoPlayerController>();
    controller.initializePlayer(widget.videoPath);
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
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player
            Center(
              child: CustomVideoPlayer(
                videoPath: widget.videoPath,
                videoTitle: widget.videoTitle,
              ),
            ),

            // Controls Overlay
            VideoControlsOverlay(
              videoTitle: widget.videoTitle,
              videoPath: widget.videoPath,
            ),
          ],
        ),
      ),
    );
  }
}
