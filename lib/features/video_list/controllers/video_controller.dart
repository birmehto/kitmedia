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
      // Debug permission status
      final permissionStatus = await _videoScanner.getPermissionStatus();
      appLog('🔍 Permission status: $permissionStatus');

      // Test directory access
      final accessResults = await _videoScanner.testDirectoryAccess();
      appLog('🔍 Directory access test:');
      for (final result in accessResults) {
        appLog('  $result');
      }

      // Scan for videos (this will handle permissions internally)
      final videos = await _videoScanner.scanForVideos();
      _videos.assignAll(videos);
      appLog('Found ${videos.length} videos');
      appLog('video names: ${videos.map((e) => e.name).toList()}');

      return videos;
    }, successMessage: 'Found ${_videos.length} videos');
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> deleteVideo(VideoFile video) async {
    final success = await _deleteService.deleteVideo(video);
    if (success) {
      _videos.remove(video);
      appLog('Video removed from list: ${video.name}');
    }
  }

  @override
  Future<void> refresh() async {
    await scanVideos();
  }
}
