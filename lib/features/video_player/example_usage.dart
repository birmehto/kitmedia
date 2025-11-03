// Example usage of the improved video player with better_player_plus

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/video_player_binding.dart';
import 'views/video_player_screen.dart';

class VideoPlayerExample extends StatelessWidget {
  const VideoPlayerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Example: Navigate to video player with a video file
            Get.to(
              () => const VideoPlayerScreen(
                videoPath: '/path/to/your/video.mp4',
                videoTitle: 'Sample Video',
              ),
              binding: VideoPlayerBinding(),
            );
          },
          child: const Text('Play Video'),
        ),
      ),
    );
  }
}

// Alternative usage with GetX routing
class VideoPlayerRoutes {
  static const String videoPlayer = '/video-player';

  static List<GetPage> routes = [
    GetPage(
      name: videoPlayer,
      page: () => VideoPlayerScreen(
        videoPath: Get.arguments['videoPath'] ?? '',
        videoTitle: Get.arguments['videoTitle'] ?? 'Video',
      ),
      binding: VideoPlayerBinding(),
    ),
  ];

  // Helper method to navigate to video player
  static void playVideo({
    required String videoPath,
    required String videoTitle,
  }) {
    Get.toNamed(
      videoPlayer,
      arguments: {'videoPath': videoPath, 'videoTitle': videoTitle},
    );
  }
}
