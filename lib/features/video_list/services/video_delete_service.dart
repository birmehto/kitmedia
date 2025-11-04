import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/native_video_delete_service.dart';
import '../../../core/utils/logger.dart';
import '../models/video_file.dart';

enum DeleteResult { success, fileNotFound, permissionDenied, otherError }

class VideoDeleteService {
  final NativeVideoDeleteService _nativeService = NativeVideoDeleteService();

  /// Deletes a video file using native Android MediaStore API
  Future<DeleteResult> deleteVideoWithResult(VideoFile video) async {
    try {
      appLog('🗑️ Attempting native deletion: ${video.path}');

      // First check if file exists using native method
      final exists = await _nativeService.fileExists(video.path);
      if (!exists) {
        appLog('✅ File does not exist (native check): ${video.path}');
        return DeleteResult.fileNotFound;
      }

      // Get video info for logging
      final videoInfo = await _nativeService.getVideoInfo(video.path);
      if (videoInfo != null && videoInfo['exists'] == true) {
        appLog(
          '📊 Native video info - Size: ${videoInfo['size']} bytes, Duration: ${videoInfo['duration']}ms',
        );
      }

      // Check if we need permission dialog (with fallback)
      bool needsPermission = false;
      try {
        needsPermission = await _nativeService.needsDeletePermission();
        if (needsPermission) {
          appLog('Android will ask for permission to delete this video');
        }
      } catch (e) {
        appLog(
          '⚠️ Could not check permission requirement, proceeding with deletion',
        );
      }

      // Attempt native deletion using MediaStore API
      appLog('🔄 Using native MediaStore deletion...');
      final deleted = await _nativeService.deleteVideo(video.path);
      appLog('📱 Native deletion completed with result: $deleted');

      if (deleted) {
        appLog(
          '✅ Successfully deleted video using native method: ${video.name}',
        );

        return DeleteResult.success;
      } else {
        appLog(
          '❌ Native deletion failed or was cancelled by user: ${video.path}',
        );

        // Check if file still exists to determine the reason for failure
        final stillExists = await _nativeService.fileExists(video.path);
        appLog('📋 File still exists after deletion attempt: $stillExists');

        if (stillExists) {
          if (needsPermission) {
            appLog('Permission Denied');
          } else {
            appLog('Cannot delete this video - it may be protected or in use');
          }
          return DeleteResult.permissionDenied;
        } else {
          // File doesn't exist anymore, so deletion actually succeeded
          appLog('✅ File was actually deleted despite false result');

          return DeleteResult.success;
        }
      }
    } catch (e) {
      appLog('❌ Unexpected error in native deletion: $e');
      appLog('Failed to delete video: ${e.toString()}');
      return DeleteResult.otherError;
    }
  }

  /// Deletes a video file from the device (legacy method for backward compatibility)
  Future<bool> deleteVideo(VideoFile video) async {
    final result = await deleteVideoWithResult(video);
    return result == DeleteResult.success;
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

  /// Show helpful suggestions when deletion fails
  void showDeletionHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cannot Delete File'),
        content: const Text(
          'If you cannot delete a video file, try:\n\n'
          '• Close any video players or file managers\n'
          '• Restart the app and try again\n'
          '• Use your device\'s file manager to delete it\n'
          '• Check if the file is on an SD card that\'s write-protected\n'
          '• Some system files cannot be deleted for security',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
