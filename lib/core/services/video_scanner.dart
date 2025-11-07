import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/video_list/models/video_file.dart';
import '../utils/logger.dart';

/// Represents a simple video model (customize for your app)
// class VideoFile {
//   final String id;
//   final String name;
//   final String path;
//   final int size;
//   final DateTime lastModified;
//
//   const VideoFile({
//     required this.id,
//     required this.name,
//     required this.path,
//     required this.size,
//     required this.lastModified,
//   });
//
//   VideoFile copyWith({
//     String? id,
//     String? name,
//     String? path,
//     int? size,
//     DateTime? lastModified,
//   }) {
//     return VideoFile(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       path: path ?? this.path,
//       size: size ?? this.size,
//       lastModified: lastModified ?? this.lastModified,
//     );
//   }
// }

class VideoScanner {
  static const List<String> _videoExts = [
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.webm',
    '.m4v',
    '.3gp',
  ];

  /// Main entry point
  Future<List<VideoFile>> scan({List<String>? customDirs}) async {
    try {
      if (!await _checkPermissions()) {
        appLog('⚠️ Permissions denied, scanning app dirs only...');
        return _scanAppDirs();
      }

      final paths = customDirs ?? await _getAllStoragePaths();
      appLog('📂 Found ${paths.length} storage roots...');

      final tasks = paths
          .map((p) => compute(_scanDirectoryInIsolate, p))
          .toList();
      final results = await Future.wait(tasks);

      final allVideos = results.expand((e) => e).toList();
      return _deduplicate(allVideos);
    } catch (e) {
      appLog('❌ Scan error: $e');
      return [];
    }
  }

  /// Permissions
  Future<bool> _checkPermissions() async {
    try {
      final sdk = await _androidSdkVersion();
      final permission = sdk >= 33 ? Permission.videos : Permission.storage;

      if (await permission.isGranted) return true;
      return (await permission.request()).isGranted;
    } catch (e) {
      appLog('❌ Permission check failed: $e');
      return false;
    }
  }

  Future<int> _androidSdkVersion() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) {
      return 30;
    }
  }

  /// Internal + SD card + App storage
  Future<List<String>> _getAllStoragePaths() async {
    final paths = <String>{};

    try {
      final internal = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
      final base = internal.replaceAll('/Download', '');
      if (_isAccessible(base)) paths.add(base);

      final externals = await ExternalPath.getExternalStorageDirectories();
      if (externals != null) {
        for (final p in externals) {
          if (p != base && _isAccessible(p)) {
            appLog('💽 Added SD card path: $p');
            paths.add(p);
          }
        }
      }

      paths.addAll(await _getAppDirs());
    } catch (e) {
      appLog('⚠️ Error fetching storage paths: $e');
      paths.add('/storage/emulated/0');
    }

    return paths.toList();
  }

  Future<List<String>> _getAppDirs() async {
    final dirs = <String>[];
    try {
      final ext = await getExternalStorageDirectory();
      final dl = await getDownloadsDirectory();
      if (ext != null) dirs.add(ext.path);
      if (dl != null) dirs.add(dl.path);
    } catch (e) {
      appLog('⚠️ Error fetching app dirs: $e');
    }
    return dirs;
  }

  /// App-only fallback scan
  Future<List<VideoFile>> _scanAppDirs() async {
    final videos = <VideoFile>[];
    for (final p in await _getAppDirs()) {
      final dir = Directory(p);
      if (dir.existsSync()) {
        final partial = await compute(_scanDirectoryInIsolate, p);
        videos.addAll(partial);
      }
    }
    return _deduplicate(videos);
  }

  /// Isolate scanning function (runs in background thread)
  @pragma('vm:entry-point')
  static Future<List<VideoFile>> _scanDirectoryInIsolate(String root) async {
    final videos = <VideoFile>[];
    final rootDir = Directory(root);

    if (!rootDir.existsSync()) return videos;
    final skipDirs = {'proc', 'sys', 'dev', 'lost+found',};

    Future<void> walk(Directory dir) async {
      try {
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is Directory) {
            final name = entity.path.split('/').last.toLowerCase();
            if (name.startsWith('.') ||
                entity.path.contains('/android/data') ||
                entity.path.contains('/android/obb') ||
                skipDirs.contains(name) ||
                entity.path.split('/').length > 10) {
              continue;
            }
            await walk(entity);
          } else if (entity is File) {
            final path = entity.path.toLowerCase();
            final extIndex = path.lastIndexOf('.');
            if (extIndex == -1) continue;
            final ext = path.substring(extIndex);

            if (_videoExts.contains(ext) || _isVideoMime(path)) {
              try {
                final stat = entity.statSync();
                if (stat.size > 0) {
                  videos.add(
                    VideoFile(
                      id: stat.modified.millisecondsSinceEpoch.toString(),
                      name: entity.uri.pathSegments.last,
                      path: entity.path,
                      size: stat.size,
                      lastModified: stat.modified,
                    ),
                  );
                }
              } catch (e) {
                appLog('Error=> ${e.toString()}');
              }
            }
          }
        }
      } catch (e) {
        appLog('Error=> ${e.toString()}');
      }
    }

    await walk(rootDir);
    return videos;
  }

  static bool _isVideoMime(String path) {
    try {
      final mime = lookupMimeType(path);
      return mime?.startsWith('video/') ?? false;
    } catch (_) {
      return false;
    }
  }

  bool _isAccessible(String path) =>
      !path.contains('/android/data') &&
      !path.contains('/android/obb') &&
      Directory(path).existsSync();

  /// Remove duplicates
  List<VideoFile> _deduplicate(List<VideoFile> videos) {
    final map = <String, VideoFile>{};
    for (final v in videos) {
      final key =
          '${v.name}_${v.size}_${v.lastModified.millisecondsSinceEpoch}';
      map[key] = v;
    }
    final unique = map.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    appLog('✅ Found ${unique.length} unique videos');
    return unique;
  }
}
