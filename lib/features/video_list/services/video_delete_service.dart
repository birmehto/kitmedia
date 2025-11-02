import 'dart:io';

import 'package:get/get.dart';

import '../../../core/utils/logger.dart';
import '../models/video_file.dart';

class VideoDeleteService {
  /// Deletes a video file from the device
  Future<bool> deleteVideo(VideoFile video) async {
    try {
      final file = File(video.path);

      if (!file.existsSync()) {
        appLog('File does not exist: ${video.path}');
        Get.snackbar(
          'Error',
          'File not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await file.delete();

      appLog('Successfully deleted video: ${video.name}');
      Get.snackbar(
        'Success',
        'Video deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      appLog('Error deleting video: $e');
      Get.snackbar(
        'Error',
        'Failed to delete video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Deletes multiple video files
  Future<int> deleteMultipleVideos(List<VideoFile> videos) async {
    int deletedCount = 0;

    for (final video in videos) {
      final success = await deleteVideo(video);
      if (success) deletedCount++;
    }

    return deletedCount;
  }
}
