import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileUtils {
  /// Pick video files from device storage
  static Future<List<File>?> pickVideoFiles({bool allowMultiple = true}) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick any media files (video, audio, images)
  static Future<List<File>?> pickMediaFiles({bool allowMultiple = true}) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Open file with external application
  static Future<bool> openWithExternalApp(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      return false;
    }
  }

  /// Share file with other apps
  static Future<void> shareFile(String filePath, {String? text}) async {
    try {
      final file = XFile(filePath);
      await SharePlus.instance.share(ShareParams(files: [file], text: text));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Share multiple files
  static Future<void> shareFiles(List<String> filePaths, {String? text}) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await SharePlus.instance.share(ShareParams(files: files, text: text));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get MIME type of a file
  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  /// Check if file is a video
  static bool isVideoFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('video/') ?? false;
  }

  /// Check if file is an audio file
  static bool isAudioFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('audio/') ?? false;
  }

  /// Check if file is an image
  static bool isImageFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('image/') ?? false;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get app documents directory
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get app cache directory
  static Future<Directory> getAppCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Create directory if it doesn't exist
  static Future<Directory> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Delete file safely
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copy file to destination
  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      // Ensure destination directory exists
      await ensureDirectoryExists(destinationFile.parent.path);

      await sourceFile.copy(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Move file to destination
  static Future<bool> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      // Ensure destination directory exists
      await ensureDirectoryExists(destinationFile.parent.path);

      await sourceFile.rename(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1) {
      return fileName.substring(0, lastDotIndex);
    }
    return fileName;
  }

  /// Get file name with extension
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Check if file exists
  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Get directory size recursively
  static Future<int> getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return size;
  }
}
