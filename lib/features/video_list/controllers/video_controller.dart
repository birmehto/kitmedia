import 'dart:io';

import 'package:get/get.dart';

import '../../../core/controllers/base_controller.dart';
import '../../../core/services/video_scanner.dart';
import '../../../core/utils/logger.dart';
import '../models/video_file.dart';
import '../services/video_delete_service.dart';

class VideoController extends BaseController {
  final RxList<VideoFile> _videos = <VideoFile>[].obs;
  final RxString _searchQuery = ''.obs;

  List<VideoFile> get videos => _videos;
  String get searchQuery => _searchQuery.value;

  List<VideoFile> get filteredVideos {
    if (_searchQuery.value.isEmpty) {
      return _videos;
    }
    return _videos.where((video) {
      return video.name.toLowerCase().contains(
            _searchQuery.value.toLowerCase(),
          ) ||
          video.path.toLowerCase().contains(_searchQuery.value.toLowerCase());
    }).toList();
  }

  final VideoScanner _videoScanner = VideoScanner();
  final VideoDeleteService _deleteService = VideoDeleteService();

  Future<void> scanVideos() async {
    await executeWithLoading(() async {
      // Test directory access and permissions
      final accessResults = await _videoScanner.testDirectoryAccess();
      appLog('🔍 Directory access test:');
      for (final result in accessResults) {
        appLog('  $result');
      }

      // Scan for videos (this will handle permissions internally)
      final videos = await _videoScanner.scanForVideos();

      // Validate the found videos to ensure they still exist
      final validVideos = await _videoScanner.validateVideoFiles(videos);

      _videos.assignAll(validVideos);
      appLog('✅ Found ${validVideos.length} valid videos');

      return validVideos;
    }, successMessage: 'Found ${_videos.length} videos');
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> deleteVideo(VideoFile video) async {
    final result = await _deleteService.deleteVideoWithResult(video);

    switch (result) {
      case DeleteResult.success:
        _videos.remove(video);
        appLog(
          'Video successfully deleted and removed from list: ${video.name}',
        );
        break;
      case DeleteResult.fileNotFound:
        // File doesn't exist, remove it from list anyway
        _videos.remove(video);
        appLog('Removed non-existent video from list: ${video.name}');

        break;
      case DeleteResult.permissionDenied:
      case DeleteResult.otherError:
        // Keep the video in the list since deletion failed for other reasons
        appLog('Failed to delete video, keeping in list: ${video.name}');
        break;
    }
  }

  /// Validate current video list and remove non-existent files
  Future<void> validateCurrentVideos() async {
    if (_videos.isEmpty) return;

    final validVideos = await _videoScanner.validateVideoFiles(_videos);
    final removedCount = _videos.length - validVideos.length;

    if (removedCount > 0) {
      _videos.assignAll(validVideos);
      appLog('🧹 Cleaned up $removedCount invalid videos from current list');

      // Show user feedback if significant cleanup happened
      if (removedCount > 3) {
        appLog('Removed $removedCount missing files from list');
      }
    }
  }

  /// Force cleanup of invalid videos
  Future<void> cleanupInvalidVideos() async {
    await executeWithLoading(() async {
      await validateCurrentVideos();
      return _videos.length;
    }, successMessage: 'Video list cleaned up');
  }

  /// Remove all non-existent files from the current list immediately
  Future<void> removeNonExistentFiles() async {
    if (_videos.isEmpty) return;

    final existingVideos = <VideoFile>[];
    int removedCount = 0;

    for (final video in _videos) {
      final file = File(video.path);
      if (file.existsSync()) {
        existingVideos.add(video);
      } else {
        removedCount++;
        appLog('🗑️ Removing non-existent file: ${video.name}');
      }
    }

    if (removedCount > 0) {
      _videos.assignAll(existingVideos);
      appLog('🧹 Removed $removedCount non-existent files from list');
    } else {
      appLog('All videos in your list exist on the device');
    }
  }

  @override
  Future<void> refresh() async {
    await scanVideos();
  }

  /// Quick fix for the current issue - call this to clean up stale files
  Future<void> fixStaleFiles() async {
    appLog('🔧 Starting stale file cleanup...');
    await removeNonExistentFiles();
    appLog('✅ Stale file cleanup completed');
  }

  @override
  void onInit() {
    super.onInit();
    // Automatically validate videos when controller initializes
    ever(_videos, (_) {
      // Validate videos periodically when list changes
      validateCurrentVideos();
    });
  }
}
