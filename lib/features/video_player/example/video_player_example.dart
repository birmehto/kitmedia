import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bindings/video_player_binding.dart';
import '../controllers/video_player_controller.dart';
import '../views/video_player_screen.dart';

/// Example demonstrating how to use the enhanced video player
class VideoPlayerExample extends StatefulWidget {
  const VideoPlayerExample({super.key});

  @override
  State<VideoPlayerExample> createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample> {
  final List<VideoItem> _sampleVideos = [
    const VideoItem(
      title: 'Sample Video 1',
      path: '/path/to/video1.mp4',
      thumbnail: '/path/to/thumbnail1.jpg',
      duration: Duration(minutes: 5, seconds: 30),
    ),
    const VideoItem(
      title: 'Sample Video 2',
      path: '/path/to/video2.mp4',
      thumbnail: '/path/to/thumbnail2.jpg',
      duration: Duration(minutes: 10, seconds: 15),
    ),
    const VideoItem(
      title: 'Sample Video 3',
      path: '/path/to/video3.mp4',
      thumbnail: '/path/to/thumbnail3.jpg',
      duration: Duration(minutes: 3, seconds: 45),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Video Player'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleVideos.length,
        itemBuilder: (context, index) {
          final video = _sampleVideos[index];
          return _buildVideoCard(video, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPlaylistExample,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.playlist_play),
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video, int index) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _playVideo(video, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(video.duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to play with enhanced controls',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Play button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo(VideoItem video, int index) {
    // Set up playlist
    final videoPaths = _sampleVideos.map((v) => v.path).toList();

    // Navigate to video player with binding
    Get.to(
      () => VideoPlayerScreen(videoPath: video.path, videoTitle: video.title),
      binding: VideoPlayerBinding(),
    )?.then((_) {
      // Optional: Handle return from video player
      debugPrint('Returned from video player');
    });

    // Configure playlist after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<VideoPlayerController>(tag: video.path);
      controller.setPlaylist(videoPaths, startIndex: index);
    });
  }

  void _showPlaylistExample() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Enhanced Video Player Features',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Features list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFeatureItem(
                    icon: Icons.gesture,
                    title: 'Gesture Controls',
                    description:
                        'Swipe left/right for brightness/volume control',
                  ),
                  _buildFeatureItem(
                    icon: Icons.speed,
                    title: 'Playback Speed',
                    description: 'Adjust playback speed from 0.25x to 2x',
                  ),
                  _buildFeatureItem(
                    icon: Icons.playlist_play,
                    title: 'Playlist Support',
                    description: 'Navigate between multiple videos seamlessly',
                  ),
                  _buildFeatureItem(
                    icon: Icons.screenshot,
                    title: 'Screenshot Capture',
                    description: 'Take screenshots of video frames',
                  ),
                  _buildFeatureItem(
                    icon: Icons.fullscreen,
                    title: 'Fullscreen Mode',
                    description: 'Immersive fullscreen video experience',
                  ),
                  _buildFeatureItem(
                    icon: Icons.subtitles,
                    title: 'Subtitle Support',
                    description: 'Load and display SRT subtitle files',
                  ),
                  _buildFeatureItem(
                    icon: Icons.hd,
                    title: 'Quality Selection',
                    description: 'Choose from multiple video quality options',
                  ),
                  _buildFeatureItem(
                    icon: Icons.loop,
                    title: 'Loop & Repeat',
                    description: 'Loop individual videos or entire playlists',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class VideoItem {
  const VideoItem({
    required this.title,
    required this.path,
    required this.thumbnail,
    required this.duration,
  });

  final String title;
  final String path;
  final String thumbnail;
  final Duration duration;
}

/// Example of how to use the video player programmatically
class VideoPlayerProgrammaticExample {
  static void playVideoWithCustomSettings({
    required String videoPath,
    required String videoTitle,
    List<String>? playlist,
    bool autoPlay = true,
    bool loop = false,
    double playbackSpeed = 1.0,
    bool gesturesEnabled = true,
  }) {
    // Navigate to video player
    Get.to(
      () => VideoPlayerScreen(videoPath: videoPath, videoTitle: videoTitle),
      binding: VideoPlayerBinding(),
    );

    // Configure settings after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<VideoPlayerController>(tag: videoPath);

      // Set playlist if provided
      if (playlist != null && playlist.isNotEmpty) {
        final startIndex = playlist.indexOf(videoPath);
        controller.setPlaylist(
          playlist,
          startIndex: startIndex >= 0 ? startIndex : 0,
        );
      }

      // Configure settings
      controller.setLoop(loop);
      controller.setSpeed(playbackSpeed);
      controller.setGesturesEnabled(gesturesEnabled);

      // Auto play if enabled
      if (autoPlay) {
        controller.play();
      }
    });
  }

  static void playVideoWithSubtitles({
    required String videoPath,
    required String videoTitle,
    required String subtitlePath,
  }) {
    // This would be implemented with subtitle loading
    playVideoWithCustomSettings(videoPath: videoPath, videoTitle: videoTitle);

    // Load subtitles after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Implementation would load and parse SRT file
      // final controller = Get.find<VideoPlayerController>(tag: videoPath);
      // controller.loadSubtitles(subtitlePath);
    });
  }
}
