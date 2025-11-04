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

  final VideoScanner _videoScanner = VideoScanner();
  final VideoDeleteService _deleteService = VideoDeleteService();

  List<VideoFile> get videos => _videos;
  String get searchQuery => _searchQuery.value;

  /// Computed filtered list
  List<VideoFile> get filteredVideos {
    final query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return _videos;
    return _videos.where((v) {
      final name = v.name.toLowerCase();
      final path = v.path.toLowerCase();
      return name.contains(query) || path.contains(query);
    }).toList();
  }

  /// Scan all storage (internal + SD + app dirs)
  Future<void> scanVideos() async {
    await executeWithLoading(() async {
      appLog('🔍 Starting video scan...');

      final videos = await _videoScanner.scan();
      if (videos.isEmpty) {
        appLog('⚠️ No videos found during scan.');
      }

      // Validate found files (ensure they still exist)
      final validVideos = await _validateVideos(videos);
      _videos.assignAll(validVideos);

      appLog('✅ Found ${validVideos.length} valid videos.');
      return validVideos;
    }, successMessage: 'Found ${_videos.length} videos');
  }

  /// Search helpers
  void updateSearchQuery(String query) => _searchQuery.value = query;
  void clearSearch() => _searchQuery.value = '';

  /// Delete a video and update list accordingly
  Future<void> deleteVideo(VideoFile video) async {
    final result = await _deleteService.deleteVideoWithResult(video);
    switch (result) {
      case DeleteResult.success:
      case DeleteResult.fileNotFound:
        _videos.remove(video);
        appLog('🗑️ Removed video: ${video.name}');
        break;
      case DeleteResult.permissionDenied:
      case DeleteResult.otherError:
        appLog('⚠️ Failed to delete: ${video.name}');
        break;
    }
  }

  /// Validate & filter only existing files
  Future<List<VideoFile>> _validateVideos(List<VideoFile> videos) async {
    final valid = <VideoFile>[];
    for (final v in videos) {
      if (await File(v.path).exists()) valid.add(v);
    }
    return valid;
  }

  /// Clean up invalid videos already in memory
  Future<void> validateCurrentVideos() async {
    if (_videos.isEmpty) return;
    final validVideos = await _validateVideos(_videos);
    final removed = _videos.length - validVideos.length;

    if (removed > 0) {
      _videos.assignAll(validVideos);
      appLog('🧹 Cleaned $removed invalid videos.');
    }
  }

  /// Manual cleanup
  Future<void> cleanupInvalidVideos() async {
    await executeWithLoading(() async {
      await validateCurrentVideos();
      return _videos.length;
    }, successMessage: 'Video list cleaned');
  }

  /// Remove missing files instantly
  Future<void> removeNonExistentFiles() async {
    if (_videos.isEmpty) return;

    final existing = <VideoFile>[];
    int removedCount = 0;

    for (final v in _videos) {
      if (File(v.path).existsSync()) {
        existing.add(v);
      } else {
        removedCount++;
        appLog('🗑️ Removing missing: ${v.name}');
      }
    }

    if (removedCount > 0) {
      _videos.assignAll(existing);
      appLog('🧹 Removed $removedCount non-existent files.');
    } else {
      appLog('✅ All videos are valid.');
    }
  }

  /// For manual stale-file fix
  Future<void> fixStaleFiles() async {
    appLog('🔧 Fixing stale files...');
    await removeNonExistentFiles();
    appLog('✅ Stale file cleanup complete.');
  }

  @override
  Future<void> refresh() async => scanVideos();

  @override
  void onInit() {
    super.onInit();
    // Auto-validate when list changes
    ever(_videos, (_) => validateCurrentVideos());
  }
}
