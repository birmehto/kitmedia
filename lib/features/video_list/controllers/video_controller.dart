import 'package:get/get.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/services/video_scanner.dart';
import '../../../core/utils/logger.dart';
import '../models/video_file.dart';

class VideoController extends GetxController {
  final RxList<VideoFile> _videos = <VideoFile>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<VideoFile> get videos => _videos;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

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

  final PermissionService _permissionService = PermissionService();
  final VideoScanner _videoScanner = VideoScanner();

  Future<void> scanVideos() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final hasPermission = await _permissionService.requestStoragePermission();

      if (!hasPermission) {
        _errorMessage.value = 'Storage permission denied';
        return;
      }

      final videos = await _videoScanner.scanForVideos();
      _videos.assignAll(videos);
      appLog('Found ${videos.length} videos');
      appLog('video names: ${videos.map((e) => e.name).toList()}');
    } catch (error) {
      _errorMessage.value = error.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  @override
  Future<void> refresh() async {
    await scanVideos();
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
