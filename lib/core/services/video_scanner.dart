import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/video_list/models/video_file.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class VideoScanner {
  static const List<String> videoExtensions =
      AppConfig.supportedVideoExtensions;

  /// Test storage access and permissions
  Future<List<String>> testDirectoryAccess() async {
    final results = <String>[];

    try {
      // Test permissions
      final hasPermissions = await _hasPermissions();
      results.add(
        '🔐 Permissions: ${hasPermissions ? "✅ Granted" : "❌ Denied"}',
      );

      // Test storage paths
      final paths = await _getAllStoragePaths();
      results.add('💾 Storage paths found: ${paths.length}');

      for (final path in paths) {
        final accessible = await _testPathAccess(path);
        results.add('  ${accessible ? "✅" : "❌"} $path');
      }
    } catch (e) {
      results.add('❌ Test error: $e');
    }

    return results;
  }

  /// Check and request permissions
  Future<bool> _hasPermissions() async {
    try {
      final androidVersion = await _getAndroidVersion();
      final permission = androidVersion >= 33
          ? Permission.videos
          : Permission.storage;

      if (await permission.isGranted) return true;

      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      appLog('❌ Permission error: $e');
      return false;
    }
  }

  Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 30; // Default to Android 11
    }
  }

  /// Scan for video files
  Future<List<VideoFile>> scanForVideos({
    List<String>? customDirectories,
  }) async {
    try {
      final hasPermissions = await _hasPermissions();
      final paths = customDirectories ?? await _getAllStoragePaths();

      if (!hasPermissions) {
        appLog('⚠️ Limited permissions - scanning app directories only');
        return await _scanAppDirectories();
      }

      appLog('📂 Scanning ${paths.length} directories...');
      final videos = <VideoFile>[];

      for (final path in paths) {
        final dir = Directory(path);
        if (dir.existsSync()) {
          await _scanDirectory(dir, videos);
        }
      }

      return _processResults(videos);
    } catch (e) {
      appLog('❌ Scan error: $e');
      return [];
    }
  }

  /// Get all storage paths
  Future<List<String>> _getAllStoragePaths() async {
    final pathSet = <String>{};

    try {
      // Internal storage
      final internalPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
      final basePath = internalPath.replaceAll('/Download', '');
      pathSet.addAll(_getVideoDirectories(basePath));

      // External storage (SD cards)
      final externalPaths = await ExternalPath.getExternalStorageDirectories();
      if (externalPaths != null) {
        for (final path in externalPaths) {
          // Skip if it's the same as internal storage
          if (path != basePath) {
            pathSet.addAll(_getVideoDirectories(path));
          }
        }
      }

      // App directories
      final appDirs = await _getAppDirectories();
      pathSet.addAll(appDirs);
    } catch (e) {
      appLog('⚠️ Error getting storage paths: $e');
      // Fallback
      pathSet.addAll(_getVideoDirectories('/storage/emulated/0'));
    }

    return pathSet.toList();
  }

  /// Get video directories for a base path
  List<String> _getVideoDirectories(String basePath) {
    final dirs = <String>[];

    // Always add the base path to scan everything
    if (Directory(basePath).existsSync() && _isAccessiblePath(basePath)) {
      dirs.add(basePath);
    }

    return dirs;
  }

  /// Check if a path is accessible without causing permission errors
  bool _isAccessiblePath(String path) {
    // Avoid paths that commonly cause permission issues
    final pathLower = path.toLowerCase();
    if (pathLower.contains('/android/data') ||
        pathLower.contains('/android/obb') ||
        pathLower.contains('/.')) {
      return false;
    }
    return true;
  }

  /// Get app-specific directories
  Future<List<String>> _getAppDirectories() async {
    final dirs = <String>[];

    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) dirs.add(externalDir.path);

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) dirs.add(downloadsDir.path);
    } catch (e) {
      appLog('⚠️ Error getting app directories: $e');
    }

    return dirs;
  }

  /// Scan app directories only (no permissions needed)
  Future<List<VideoFile>> _scanAppDirectories() async {
    final videos = <VideoFile>[];
    final appDirs = await _getAppDirectories();

    for (final path in appDirs) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        await _scanDirectory(dir, videos);
      }
    }

    return _processResults(videos);
  }

  /// Test if a path is accessible
  Future<bool> _testPathAccess(String path) async {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) return false;
      await dir.list().take(1).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Scan directory for videos
  Future<void> _scanDirectory(
    Directory directory,
    List<VideoFile> videos,
  ) async {
    try {
      // Check if we should skip this directory entirely
      if (_shouldSkipDirectory(directory.path)) {
        return;
      }

      appLog('🔍 Scanning: ${directory.path}');

      await for (final entity in directory.list(followLinks: false)) {
        if (entity is Directory) {
          // Recursively scan subdirectories if they're not skipped
          if (!_shouldSkipDirectory(entity.path)) {
            await _scanDirectory(entity, videos);
          } else {
            appLog('⏭️ Skipped: ${entity.path}');
          }
        } else if (entity is File) {
          if (_isVideoFile(entity.path)) {
            try {
              if (await _isFileAccessible(entity)) {
                final videoFile = await _createVideoFile(entity);
                videos.add(videoFile);
                appLog('📹 Found video: ${entity.path}');
              } else {
                appLog('❌ Inaccessible: ${entity.path}');
              }
            } catch (e) {
              appLog('⚠️ Error processing ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      // Only log permission errors for debugging, don't spam logs
      if (e.toString().contains('Permission denied')) {
        appLog('🔒 Permission denied: ${directory.path}');
      } else {
        appLog('⚠️ Error scanning ${directory.path}: $e');
      }
    }
  }

  bool _isVideoFile(String path) {
    final pathLower = path.toLowerCase();

    // Check by extension first
    final lastDotIndex = pathLower.lastIndexOf('.');
    if (lastDotIndex != -1) {
      final ext = pathLower.substring(lastDotIndex);
      if (videoExtensions.contains(ext)) {
        return true;
      }
    }

    // Common video extensions that might not be in config
    const commonVideoExts = {
      '.mp4',
      '.avi',
      '.mkv',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.3gp',
      '.3g2',
      '.f4v',
      '.asf',
      '.rm',
      '.rmvb',
      '.vob',
      '.ogv',
      '.drc',
      '.gif',
      '.gifv',
      '.mng',
      '.qt',
      '.yuv',
      '.roq',
      '.svi',
      '.mxf',
    };

    if (lastDotIndex != -1) {
      final ext = pathLower.substring(lastDotIndex);
      if (commonVideoExts.contains(ext)) {
        return true;
      }
    }

    // Fallback to MIME type detection
    try {
      final mimeType = lookupMimeType(path);
      if (mimeType != null && mimeType.startsWith('video/')) {
        appLog('📹 Detected by MIME: $mimeType for ${path.split('/').last}');
        return true;
      }
    } catch (e) {
      // MIME detection failed, continue
    }

    return false;
  }

  bool _shouldSkipDirectory(String path) {
    final name = path.split('/').last.toLowerCase();
    final pathLower = path.toLowerCase();

    // Skip hidden directories (starting with .)
    if (name.startsWith('.')) return true;

    // Skip Android system directories that cause permission errors
    if (pathLower.contains('/android/data') ||
        pathLower.contains('/android/obb')) {
      return true;
    }

    // Skip only critical system directories
    const criticalSkipDirs = {'proc', 'sys', 'dev', 'lost+found'};

    if (criticalSkipDirs.contains(name)) return true;

    // Skip very deep nested directories (performance) - increased limit
    if (path.split('/').length > 10) return true;

    return false;
  }

  Future<bool> _isFileAccessible(File file) async {
    try {
      final stat = file.statSync();
      return stat.type == FileSystemEntityType.file && stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  /// Create video file with duration
  Future<VideoFile> _createVideoFile(File file) async {
    final baseVideoFile = VideoFile.fromFile(file);

    try {
      final player = Player();
      await player.open(Media(file.path));

      // Wait for duration to be available
      Duration? duration;
      await for (final d in player.stream.duration) {
        if (d != Duration.zero) {
          duration = d;
          break;
        }
        // Timeout after 3 seconds
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await player.dispose();

      if (duration != null && duration != Duration.zero) {
        return baseVideoFile.copyWith(duration: duration);
      }
      return baseVideoFile;
    } catch (e) {
      return baseVideoFile;
    }
  }

  /// Validate existing video files and remove non-existent ones
  Future<List<VideoFile>> validateVideoFiles(List<VideoFile> videos) async {
    final validVideos = <VideoFile>[];
    int removedCount = 0;

    for (final video in videos) {
      try {
        final file = File(video.path);
        // ignore: avoid_slow_async_io
        if (await file.exists() && await _isFileAccessible(file)) {
          validVideos.add(video);
        } else {
          removedCount++;
          appLog('🗑️ Removed non-existent video: ${video.name}');
        }
      } catch (e) {
        removedCount++;
        appLog('⚠️ Error validating ${video.name}: $e');
      }
    }

    if (removedCount > 0) {
      appLog('🧹 Cleaned up $removedCount invalid video files');
    }

    return validVideos;
  }

  /// Process and deduplicate results
  List<VideoFile> _processResults(List<VideoFile> videos) {
    final unique = <String, VideoFile>{};

    for (final video in videos) {
      try {
        final canonical = File(video.path).resolveSymbolicLinksSync();
        unique.putIfAbsent(
          canonical,
          () => video.copyWith(
            path: canonical,
            id: canonical.hashCode.toString(),
          ),
        );
      } catch (_) {
        final key =
            '${video.name}_${video.size}_${video.lastModified.millisecondsSinceEpoch}';
        unique.putIfAbsent(key, () => video);
      }
    }

    final result = unique.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    appLog(
      '✅ Found ${result.length} unique videos (${videos.length - result.length} duplicates removed)',
    );
    return result;
  }
}
