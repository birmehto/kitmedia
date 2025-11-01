import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../features/video_list/models/video_file.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class VideoScanner {
  static const List<String> videoExtensions =
      AppConfig.supportedVideoExtensions;

  /// Scans system directories for video files.
  Future<List<VideoFile>> scanForVideos({
    List<String>? customDirectories,
  }) async {
    final List<VideoFile> videos = [];

    try {
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
    final basePaths = [
      '/storage/emulated/0', // internal
      '/sdcard', // legacy alias
    ];

    for (final path in basePaths) {
      final d = Directory(path);
      if (d.existsSync()) {
        dirs.add(d);
        appLog('📱 Added Android path: $path');
      }
    }

    // Scan /storage for extra mounted volumes (e.g., SD cards, USB OTG)
    final storageDir = Directory('/storage');
    if (storageDir.existsSync()) {
      await for (final entity in storageDir.list()) {
        if (entity is Directory) {
          final dirName = entity.path.split('/').last;
          if (dirName == 'self' || dirName == 'emulated') continue;
          dirs.add(entity);
          appLog('💾 Added external storage: ${entity.path}');
        }
      }
    }

    // App external storage
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null && externalDir.existsSync()) {
        dirs.add(externalDir);
        appLog('📂 Added app external: ${externalDir.path}');
      }
    } catch (e) {
      appLog('⚠️ Could not access app external storage: $e');
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
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is Directory && _shouldSkipDirectory(entity.path)) continue;

        if (entity is File && _isVideoFile(entity.path)) {
          try {
            final videoFile = await _createVideoFileWithDuration(entity);
            videos.add(videoFile);
          } catch (_) {
            // Skip broken files
          }
        }
      }
    } catch (e) {
      appLog('⚠️ Error scanning ${directory.path}: $e');
    }
  }

  bool _isVideoFile(String path) {
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex == -1) return false; // No extension

    final ext = path.toLowerCase().substring(lastDotIndex);
    return videoExtensions.contains(ext);
  }

  bool _shouldSkipDirectory(String path) {
    final name = path.split('/').last.toLowerCase();
    if (name.startsWith('.')) return true; // hidden
    const systemDirs = {
      'android_secure',
      'system',
      'proc',
      'sys',
      'dev',
      'cache',
      'tmp',
    };
    return systemDirs.contains(name);
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
