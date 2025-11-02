import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../features/video_list/models/video_file.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class VideoScanner {
  static const List<String> videoExtensions =
      AppConfig.supportedVideoExtensions;

  /// Get permission status information for debugging
  Future<Map<String, dynamic>> getPermissionStatus() async {
    if (!Platform.isAndroid) {
      return {'platform': 'non-android', 'hasPermissions': true};
    }

    try {
      final storageStatus = await Permission.storage.status;
      final videosStatus = await Permission.videos.status;

      return {
        'platform': 'android',
        'storage': storageStatus.toString(),
        'videos': videosStatus.toString(),
        'hasPermissions': storageStatus.isGranted || videosStatus.isGranted,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Test method to check basic directory access
  Future<List<String>> testDirectoryAccess() async {
    final results = <String>[];

    try {
      // Test basic directories
      final testDirs = ['/storage/emulated/0', '/sdcard'];

      for (final path in testDirs) {
        final dir = Directory(path);
        if (dir.existsSync()) {
          try {
            final entities = await dir.list().take(5).toList();
            results.add('✅ $path - accessible (${entities.length} items)');
          } catch (e) {
            results.add('❌ $path - exists but not accessible: $e');
          }
        } else {
          results.add('⚠️ $path - does not exist');
        }
      }

      // Test app directories
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          results.add('✅ App external: ${externalDir.path}');
        }
      } catch (e) {
        results.add('❌ App external error: $e');
      }
    } catch (e) {
      results.add('❌ Test error: $e');
    }

    return results;
  }

  /// Check if storage permissions are granted
  Future<bool> hasStoragePermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidVersion = await _getAndroidVersion();
      appLog('📱 Android version: $androidVersion');

      // For Android 13+ (API 33+), use READ_MEDIA_VIDEO
      // For older versions, use READ_EXTERNAL_STORAGE
      if (androidVersion >= 33) {
        final videosGranted = await Permission.videos.isGranted;
        appLog('🔍 Videos permission (Android 13+): $videosGranted');
        return videosGranted;
      } else {
        final storageGranted = await Permission.storage.isGranted;
        appLog('🔍 Storage permission (Android <13): $storageGranted');
        return storageGranted;
      }
    } catch (e) {
      appLog('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      appLog('⚠️ Could not get Android version: $e');
      return 30; // Default to Android 11 (API 30)
    }
  }

  /// Request storage permissions with user-friendly handling
  Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidVersion = await _getAndroidVersion();
      appLog(
        '📋 Requesting storage permissions for Android $androidVersion...',
      );

      Permission targetPermission;
      if (androidVersion >= 33) {
        targetPermission = Permission.videos;
        appLog('📋 Using READ_MEDIA_VIDEO permission for Android 13+');
      } else {
        targetPermission = Permission.storage;
        appLog('📋 Using READ_EXTERNAL_STORAGE permission for Android <13');
      }

      final status = await targetPermission.request();
      appLog('📋 Permission result: $status');

      switch (status) {
        case PermissionStatus.granted:
          appLog('✅ Storage permissions granted');
          return true;
        case PermissionStatus.denied:
          appLog('❌ Storage permissions denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          appLog(
            '❌ Storage permissions permanently denied - please enable in settings',
          );
          return false;
        default:
          appLog('⚠️ Storage permission status: $status');
          return false;
      }
    } catch (e) {
      appLog('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Scans system directories for video files.
  Future<List<VideoFile>> scanForVideos({
    List<String>? customDirectories,
  }) async {
    final List<VideoFile> videos = [];

    try {
      // Check and request permissions first
      if (Platform.isAndroid) {
        final hasPermissions = await requestStoragePermissions();
        if (!hasPermissions) {
          appLog(
            '⚠️ Storage permissions not granted, trying app-specific directories only',
          );
          // Fallback to app-specific directories that don't require permissions
          return await _scanAppSpecificDirectories();
        }
      }

      final directories = customDirectories != null
          ? customDirectories.map((e) => Directory(e)).toList()
          : await _getDirectoriesToScan();

      appLog('📂 Scanning ${directories.length} directories for videos...');

      for (final dir in directories) {
        if (dir.existsSync()) {
          await _scanDirectory(dir, videos);
        }
      }
    } catch (e, st) {
      appLog('❌ Error scanning for videos: $e\n$st');
    }

    final uniqueVideos = _removeDuplicates(videos);
    uniqueVideos.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    appLog('✅ Found ${uniqueVideos.length} unique videos');
    return uniqueVideos;
  }

  /// Fallback method to scan app-specific directories when permissions are denied
  Future<List<VideoFile>> _scanAppSpecificDirectories() async {
    final List<VideoFile> videos = [];
    final directories = <Directory>[];

    try {
      // App external storage (doesn't require permissions)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null && externalDir.existsSync()) {
        directories.add(externalDir);
        appLog('📂 Added app external: ${externalDir.path}');
      }

      // App documents directory
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        if (docsDir.existsSync()) {
          directories.add(docsDir);
          appLog('📄 Added app documents: ${docsDir.path}');
        }
      } catch (e) {
        appLog('⚠️ Could not access app documents: $e');
      }

      appLog('📂 Scanning ${directories.length} app-specific directories...');

      for (final dir in directories) {
        await _scanDirectory(dir, videos);
      }
    } catch (e) {
      appLog('❌ Error scanning app directories: $e');
    }

    final uniqueVideos = _removeDuplicates(videos);
    uniqueVideos.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    appLog('✅ Found ${uniqueVideos.length} videos in app directories');
    return uniqueVideos;
  }

  // -------------------------------------------------
  // PLATFORM DIRECTORY HANDLING
  // -------------------------------------------------
  Future<List<Directory>> _getDirectoriesToScan() async {
    final directories = <Directory>[];
    await _addPlatformStorageDirectories(directories);
    appLog('🧭 Will scan ${directories.length} locations');
    return directories;
  }

  Future<void> _addPlatformStorageDirectories(
    List<Directory> directories,
  ) async {
    try {
      if (kIsWeb) {
        appLog('🌐 Web platform: filesystem access not available');
        return;
      }

      if (Platform.isAndroid) {
        await _addAndroidStorage(directories);
      } else if (Platform.isLinux) {
        await _addLinuxStorage(directories);
      } else if (Platform.isWindows) {
        await _addWindowsStorage(directories);
      } else if (Platform.isMacOS) {
        await _addMacStorage(directories);
      } else {
        appLog('⚠️ Unsupported platform: ${Platform.operatingSystem}');
      }
    } catch (e) {
      appLog('❌ Error detecting platform storage: $e');
    }
  }

  // -------------------------------------------------
  // ANDROID + SD CARD SUPPORT
  // -------------------------------------------------
  Future<void> _addAndroidStorage(List<Directory> dirs) async {
    // Primary internal storage paths
    final primaryPaths = [
      '/storage/emulated/0',
      '/sdcard', // legacy alias
    ];

    // Common video directories on Android
    final commonVideoDirs = [
      'DCIM',
      'Movies',
      'Download',
      'Downloads',
      'Pictures', // Sometimes videos are here
      'WhatsApp/Media/WhatsApp Video',
      'Telegram/Telegram Video',
      'Camera',
    ];

    // Add primary storage with common video directories
    for (final basePath in primaryPaths) {
      final baseDir = Directory(basePath);
      if (!baseDir.existsSync()) continue;

      // Add the base directory
      dirs.add(baseDir);
      appLog('📱 Added Android base path: $basePath');

      // Add specific video directories
      for (final videoDir in commonVideoDirs) {
        final dir = Directory('$basePath/$videoDir');
        if (dir.existsSync()) {
          dirs.add(dir);
          appLog('🎬 Added video directory: ${dir.path}');
        }
      }
    }

    // Scan for external storage (SD cards, USB OTG)
    await _addExternalStorageDirectories(dirs);

    // App-specific directories
    await _addAppSpecificDirectories(dirs);
  }

  Future<void> _addExternalStorageDirectories(List<Directory> dirs) async {
    try {
      final storageDir = Directory('/storage');
      if (!storageDir.existsSync()) return;

      await for (final entity in storageDir.list()) {
        if (entity is! Directory) continue;

        final dirName = entity.path.split('/').last;
        // Skip system directories
        if (dirName == 'self' ||
            dirName == 'emulated' ||
            dirName.startsWith('.')) {
          continue;
        }

        // This is likely an external storage device
        dirs.add(entity);
        appLog('💾 Added external storage: ${entity.path}');

        // Also add common video directories in external storage
        for (final videoDir in ['DCIM', 'Movies', 'Download', 'Downloads']) {
          final dir = Directory('${entity.path}/$videoDir');
          if (dir.existsSync()) {
            dirs.add(dir);
            appLog('🎬 Added external video dir: ${dir.path}');
          }
        }
      }
    } catch (e) {
      appLog('⚠️ Error scanning external storage: $e');
    }
  }

  Future<void> _addAppSpecificDirectories(List<Directory> dirs) async {
    try {
      // App external storage
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null && externalDir.existsSync()) {
        dirs.add(externalDir);
        appLog('📂 Added app external: ${externalDir.path}');
      }

      // Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null && downloadsDir.existsSync()) {
        dirs.add(downloadsDir);
        appLog('📥 Added downloads: ${downloadsDir.path}');
      }
    } catch (e) {
      appLog('⚠️ Could not access app directories: $e');
    }
  }

  // -------------------------------------------------
  // LINUX
  // -------------------------------------------------
  Future<void> _addLinuxStorage(List<Directory> dirs) async {
    final home = Directory(Platform.environment['HOME'] ?? '/home');
    final commonDirs = [
      Directory('${home.path}/Downloads'),
      Directory('${home.path}/Videos'),
      Directory('${home.path}/Desktop'),
      home,
    ];

    for (final d in commonDirs) {
      if (d.existsSync()) {
        dirs.add(d);
        appLog('🐧 Added Linux dir: ${d.path}');
      }
    }

    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null && downloads.existsSync()) {
        dirs.add(downloads);
        appLog('🐧 Added system downloads: ${downloads.path}');
      }
    } catch (_) {}
  }

  // -------------------------------------------------
  // WINDOWS
  // -------------------------------------------------
  Future<void> _addWindowsStorage(List<Directory> dirs) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final downloads = await getDownloadsDirectory();
      for (final d in [docs, downloads]) {
        if (d != null && d.existsSync()) {
          dirs.add(d);
          appLog('🪟 Added Windows dir: ${d.path}');
        }
      }
    } catch (e) {
      appLog('⚠️ Windows storage error: $e');
    }
  }

  // -------------------------------------------------
  // MACOS
  // -------------------------------------------------
  Future<void> _addMacStorage(List<Directory> dirs) async {
    try {
      final downloads = await getDownloadsDirectory();
      final home = Directory(Platform.environment['HOME'] ?? '/Users');
      for (final d in [home, Directory('${home.path}/Movies'), downloads]) {
        if (d != null && d.existsSync()) {
          dirs.add(d);
          appLog('🍎 Added macOS dir: ${d.path}');
        }
      }
    } catch (e) {
      appLog('⚠️ macOS storage error: $e');
    }
  }

  // -------------------------------------------------
  // SCANNING
  // -------------------------------------------------
  Future<void> _scanDirectory(
    Directory directory,
    List<VideoFile> videos,
  ) async {
    try {
      appLog('🔍 Scanning directory: ${directory.path}');

      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        // Skip directories we don't want to scan
        if (entity is Directory && _shouldSkipDirectory(entity.path)) {
          continue;
        }

        if (entity is File && _isVideoFile(entity.path)) {
          try {
            // Check if file is accessible
            if (!await _isFileAccessible(entity)) {
              appLog('⚠️ File not accessible: ${entity.path}');
              continue;
            }

            final videoFile = await _createVideoFileWithDuration(entity);
            videos.add(videoFile);
            appLog('✅ Added video: ${entity.path}');
          } catch (e) {
            appLog('⚠️ Error processing ${entity.path}: $e');
            // Skip broken files but continue scanning
          }
        }
      }
    } catch (e) {
      appLog('⚠️ Error scanning ${directory.path}: $e');
    }
  }

  Future<bool> _isFileAccessible(File file) async {
    try {
      // Try to get file stats to check if file is accessible
      final stat = file.statSync();
      return stat.type == FileSystemEntityType.file && stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isVideoFile(String path) {
    // First check by extension
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex != -1) {
      final ext = path.toLowerCase().substring(lastDotIndex);
      if (videoExtensions.contains(ext)) {
        return true;
      }
    }

    // Fallback to MIME type detection
    try {
      final mimeType = lookupMimeType(path);
      if (mimeType != null && mimeType.startsWith('video/')) {
        appLog('📹 Detected video by MIME type: $mimeType for $path');
        return true;
      }
    } catch (e) {
      // MIME detection failed, continue with extension check
    }

    return false;
  }

  bool _shouldSkipDirectory(String path) {
    final name = path.split('/').last.toLowerCase();

    // Skip hidden directories
    if (name.startsWith('.')) return true;

    // Skip system and cache directories
    const systemDirs = {
      'android_secure',
      'system',
      'proc',
      'sys',
      'dev',
      'cache',
      'tmp',
      'lost+found',
      'android',
      'data',
      'obb',
      'thumbnails',
      '.thumbnails',
      '.android_secure',
    };

    if (systemDirs.contains(name)) return true;

    // Skip app-specific cache directories
    if (name.contains('cache') ||
        name.contains('temp') ||
        name.contains('tmp')) {
      return true;
    }

    // Skip very deep nested directories (performance optimization)
    final depth = path.split('/').length;
    if (depth > 8) return true;

    return false;
  }

  // -------------------------------------------------
  // VIDEO METADATA EXTRACTION
  // -------------------------------------------------
  Future<VideoFile> _createVideoFileWithDuration(File file) async {
    final baseVideoFile = VideoFile.fromFile(file);

    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize().timeout(const Duration(seconds: 5));

      final duration = controller.value.duration;
      await controller.dispose();

      return baseVideoFile.copyWith(duration: duration);
    } catch (e) {
      appLog('⚠️ Could not get duration for ${file.path}: $e');
      return baseVideoFile;
    }
  }

  // -------------------------------------------------
  // DEDUPLICATION
  // ---------------------
  List<VideoFile> _removeDuplicates(List<VideoFile> videos) {
    final Map<String, VideoFile> unique = {};
    for (final v in videos) {
      try {
        final canonical = File(v.path).resolveSymbolicLinksSync();
        unique.putIfAbsent(
          canonical,
          () => v.copyWith(path: canonical, id: canonical.hashCode.toString()),
        );
      } catch (_) {
        final key =
            '${v.name}_${v.size}_${v.lastModified.millisecondsSinceEpoch}';
        unique.putIfAbsent(key, () => v);
      }
    }
    appLog('🧹 Removed ${videos.length - unique.length} duplicates');
    return unique.values.toList();
  }
}
