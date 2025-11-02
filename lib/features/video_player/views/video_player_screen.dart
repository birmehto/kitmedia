import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return GetBuilder<VideoPlayerController>(
      init: VideoPlayerController(),
      initState: (state) {
        // Use a post-frame callback to ensure the controller is properly initialized
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final controller = state.controller;
          if (controller != null) {
            controller.initializePlayer(videoPath);
          }
        });
      },
      dispose: (state) {
        Get.delete<VideoPlayerController>();
      },
      builder: (controller) => _VideoPlayerView(
        controller: controller,
        videoPath: videoPath,
        videoTitle: videoTitle,
      ),
    );
  }
}

class _VideoPlayerView extends StatelessWidget {
  const _VideoPlayerView({
    required this.controller,
    required this.videoPath,
    required this.videoTitle,
  });

  final VideoPlayerController controller;
  final String videoPath;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              _buildBackgroundGradient(),

              // Video Player
              Center(
                child: CustomVideoPlayer(
                  videoPath: videoPath,
                  videoTitle: videoTitle,
                ),
              ),

              // Controls Overlay
              VideoControlsOverlay(
                videoTitle: videoTitle,
                videoPath: videoPath,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1.0,
          colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
        ),
      ),
    );
  }
}
