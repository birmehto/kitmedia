import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;

import '../controllers/video_player_controller.dart';

class VideoPlaylistWidget extends StatelessWidget {
  const VideoPlaylistWidget({required this.controllerTag, super.key});

  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>(tag: controllerTag);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Symbols.playlist_play_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '${controller.currentIndex.value + 1} of ${controller.playlist.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // Playlist items
          Flexible(
            child: Obx(() {
              if (controller.playlist.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.playlist_remove_rounded,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No videos in playlist',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.playlist.length,
                itemBuilder: (context, index) {
                  final videoPath = controller.playlist[index];
                  final isCurrentVideo = index == controller.currentIndex.value;

                  return _buildPlaylistItem(
                    context,
                    videoPath,
                    index,
                    isCurrentVideo,
                    controller,
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(
    BuildContext context,
    String videoPath,
    int index,
    bool isCurrentVideo,
    VideoPlayerController controller,
  ) {
    final fileName = path.basenameWithoutExtension(videoPath);
    final fileSize = _getFileSize(videoPath);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentVideo
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentVideo
            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCurrentVideo ? Symbols.play_arrow_rounded : Symbols.movie_rounded,
            color: isCurrentVideo ? Colors.white : Colors.white70,
            size: 24,
          ),
        ),
        title: Text(
          fileName,
          style: TextStyle(
            color: isCurrentVideo ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isCurrentVideo ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          fileSize,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: isCurrentVideo
            ? const Icon(
                Symbols.volume_up_rounded,
                color: Colors.white,
                size: 20,
              )
            : null,
        onTap: () {
          if (!isCurrentVideo) {
            controller.currentIndex.value = index;
            controller.initialize(videoPath);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '${bytes}B';
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)}KB';
        }
        if (bytes < 1024 * 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
        }
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown size';
  }
}
