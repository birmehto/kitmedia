import 'package:get/get.dart';

import '../../../core/controllers/base_controller.dart';
import '../../../core/services/video_folder_organizer.dart';
import '../../../core/services/video_scanner.dart';
import '../models/video_file.dart';
import '../models/video_folder.dart';

class VideoFolderController extends BaseController {
  final VideoScanner _videoScanner = VideoScanner();

  // Reactive variables
  final RxList<VideoFolder> _folders = <VideoFolder>[].obs;
  final RxList<VideoFolder> _filteredFolders = <VideoFolder>[].obs;
  final RxString _searchQuery = ''.obs;
  final Rx<FolderSortType> _sortType = FolderSortType.name.obs;
  final RxBool _isGridView = true.obs;

  // Getters
  List<VideoFolder> get folders => _filteredFolders;
  String get searchQuery => _searchQuery.value;
  FolderSortType get sortType => _sortType.value;
  bool get isGridView => _isGridView.value;
  bool get hasFolders => _folders.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }

  /// Load and organize videos by folders
  Future<void> loadFolders() async {
    await executeWithLoading(() async {
      final videos = await _videoScanner.scanForVideos();
      final organizedFolders = VideoFolderOrganizer.organizeVideosByFolders(
        videos,
      );

      _folders.value = organizedFolders;
      _applyFiltersAndSort();

      showSuccess(
        'Found ${videos.length} videos in ${organizedFolders.length} folders',
      );
    });
  }

  /// Refresh folder list
  Future<void> refreshFolders() async {
    await loadFolders();
  }

  /// Search folders and videos
  void searchFolders(String query) {
    _searchQuery.value = query;
    _applyFiltersAndSort();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _applyFiltersAndSort();
  }

  /// Change sort type
  void changeSortType(FolderSortType newSortType) {
    _sortType.value = newSortType;
    _applyFiltersAndSort();
  }

  /// Toggle between grid and list view
  void toggleViewMode() {
    _isGridView.value = !_isGridView.value;
  }

  /// Apply current filters and sorting
  void _applyFiltersAndSort() {
    var filtered = List<VideoFolder>.from(_folders);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filtered = VideoFolderOrganizer.filterFolders(
        filtered,
        _searchQuery.value,
      );
    }

    // Apply sorting
    filtered = VideoFolderOrganizer.sortFolders(filtered, _sortType.value);

    _filteredFolders.value = filtered;
  }

  /// Get folder statistics
  Map<String, dynamic> getFolderStatistics() {
    return VideoFolderOrganizer.getFolderStatistics(_folders);
  }

  /// Get videos from a specific folder
  List<VideoFile> getVideosFromFolder(VideoFolder folder) {
    return folder.videos;
  }

  /// Get folder by path
  VideoFolder? getFolderByPath(String path) {
    try {
      return _folders.firstWhere((folder) => folder.path == path);
    } catch (e) {
      return null;
    }
  }

  /// Get total video count
  int get totalVideoCount {
    return _folders.fold(0, (sum, folder) => sum + folder.videoCount);
  }

  /// Get total size of all videos
  int get totalSize {
    return _folders.fold(0, (sum, folder) => sum + folder.totalSize);
  }

  /// Get total duration of all videos
  Duration get totalDuration {
    return _folders.fold(
      Duration.zero,
      (sum, folder) => sum + folder.totalDuration,
    );
  }

  /// Get formatted total size string
  String get totalSizeString {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    }
    if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get formatted total duration string
  String get totalDurationString {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
