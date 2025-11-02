import 'dart:io';

import '../../features/video_list/models/video_file.dart';
import '../../features/video_list/models/video_folder.dart';
import '../utils/logger.dart';

class VideoFolderOrganizer {
  /// Organize videos by their folder structure
  static List<VideoFolder> organizeVideosByFolders(List<VideoFile> videos) {
    final Map<String, List<VideoFile>> folderMap = {};

    // Group videos by folder path
    for (final video in videos) {
      final folderPath = video.folderPath ?? 'Unknown';
      folderMap.putIfAbsent(folderPath, () => []).add(video);
    }

    // Convert to VideoFolder objects
    final folders = <VideoFolder>[];
    for (final entry in folderMap.entries) {
      final folderPath = entry.key;
      final folderVideos = entry.value;

      // Get folder name from path
      final folderName = _getFolderNameFromPath(folderPath);

      // Sort videos within folder by name
      folderVideos.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      final folder = VideoFolder(
        name: folderName,
        path: folderPath,
        videos: folderVideos,
        thumbnail: _getFirstVideoThumbnail(folderVideos),
      );

      folders.add(folder);
    }

    // Sort folders by name
    folders.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    appLog(
      '📁 Organized ${videos.length} videos into ${folders.length} folders',
    );
    return folders;
  }

  /// Get a user-friendly folder name from path
  static String _getFolderNameFromPath(String folderPath) {
    if (folderPath == 'Unknown' || folderPath.isEmpty) {
      return 'Unknown';
    }

    final pathParts = folderPath.split(Platform.pathSeparator);
    if (pathParts.isEmpty) return 'Root';

    final folderName = pathParts.last;
    if (folderName.isEmpty && pathParts.length > 1) {
      return pathParts[pathParts.length - 2];
    }

    // Make common folder names more user-friendly
    return _beautifyFolderName(folderName);
  }

  /// Make folder names more user-friendly
  static String _beautifyFolderName(String folderName) {
    // Handle common Android folder names
    switch (folderName.toLowerCase()) {
      case 'dcim':
        return 'Camera';
      case 'download':
      case 'downloads':
        return 'Downloads';
      case 'movies':
        return 'Movies';
      case 'pictures':
        return 'Pictures';
      case 'whatsapp video':
        return 'WhatsApp Videos';
      case 'telegram video':
        return 'Telegram Videos';
      case '0':
        return 'Internal Storage';
      case 'emulated':
        return 'Device Storage';
      default:
        // Capitalize first letter and replace underscores/hyphens with spaces
        return folderName
            .replaceAll('_', ' ')
            .replaceAll('-', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  /// Get thumbnail from the first video in the folder
  static String? _getFirstVideoThumbnail(List<VideoFile> videos) {
    for (final video in videos) {
      if (video.thumbnail != null) {
        return video.thumbnail;
      }
    }
    return null;
  }

  /// Get folder statistics
  static Map<String, dynamic> getFolderStatistics(List<VideoFolder> folders) {
    final totalVideos = folders.fold(
      0,
      (sum, folder) => sum + folder.videoCount,
    );
    final totalSize = folders.fold(0, (sum, folder) => sum + folder.totalSize);
    final totalDuration = folders.fold(
      Duration.zero,
      (sum, folder) => sum + folder.totalDuration,
    );

    return {
      'totalFolders': folders.length,
      'totalVideos': totalVideos,
      'totalSize': totalSize,
      'totalDuration': totalDuration,
      'averageVideosPerFolder': folders.isEmpty
          ? 0
          : (totalVideos / folders.length).round(),
    };
  }

  /// Filter folders by search query
  static List<VideoFolder> filterFolders(
    List<VideoFolder> folders,
    String query,
  ) {
    if (query.isEmpty) return folders;

    final lowerQuery = query.toLowerCase();
    return folders.where((folder) {
      // Search in folder name
      if (folder.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in video names within the folder
      return folder.videos.any(
        (video) => video.name.toLowerCase().contains(lowerQuery),
      );
    }).toList();
  }

  /// Sort folders by different criteria
  static List<VideoFolder> sortFolders(
    List<VideoFolder> folders,
    FolderSortType sortType,
  ) {
    final sortedFolders = List<VideoFolder>.from(folders);

    switch (sortType) {
      case FolderSortType.name:
        sortedFolders.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case FolderSortType.videoCount:
        sortedFolders.sort((a, b) => b.videoCount.compareTo(a.videoCount));
        break;
      case FolderSortType.totalSize:
        sortedFolders.sort((a, b) => b.totalSize.compareTo(a.totalSize));
        break;
      case FolderSortType.lastModified:
        sortedFolders.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case FolderSortType.totalDuration:
        sortedFolders.sort(
          (a, b) => b.totalDuration.compareTo(a.totalDuration),
        );
        break;
    }

    return sortedFolders;
  }

  /// Get folder hierarchy (nested folders)
  static List<VideoFolder> getFolderHierarchy(List<VideoFile> videos) {
    final Map<String, Map<String, List<VideoFile>>> hierarchyMap = {};

    // Group videos by parent and child folders
    for (final video in videos) {
      final pathParts = video.path.split(Platform.pathSeparator);
      if (pathParts.length < 2) continue;

      // Get parent folder (e.g., /storage/emulated/0)
      final parentPath = pathParts
          .sublist(0, pathParts.length - 2)
          .join(Platform.pathSeparator);
      final childPath = video.folderPath ?? 'Unknown';

      hierarchyMap.putIfAbsent(parentPath, () => {});
      hierarchyMap[parentPath]!.putIfAbsent(childPath, () => []).add(video);
    }

    // Convert to flat folder list for now (can be enhanced for tree view later)
    return organizeVideosByFolders(videos);
  }
}

enum FolderSortType { name, videoCount, totalSize, lastModified, totalDuration }
