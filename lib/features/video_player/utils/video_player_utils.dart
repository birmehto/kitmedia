import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class VideoPlayerUtils {
  // Format duration to human readable string
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // Format file size to human readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  // Get file size from path
  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        return formatFileSize(file.lengthSync());
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown size';
  }

  // Get video file name without extension
  static String getVideoFileName(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  // Check if file is a video file
  static bool isVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    const videoExtensions = [
      '.mp4',
      '.avi',
      '.mkv',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.3gp',
      '.ts',
      '.mts',
      '.m2ts',
    ];
    return videoExtensions.contains(extension);
  }

  // Generate thumbnail path for video
  static String getThumbnailPath(String videoPath) {
    final dir = path.dirname(videoPath);
    final name = path.basenameWithoutExtension(videoPath);
    return path.join(dir, '.thumbnails', '$name.jpg');
  }

  // Calculate aspect ratio from resolution string
  static double calculateAspectRatio(String resolution) {
    try {
      final parts = resolution.split('x');
      if (parts.length == 2) {
        final width = double.parse(parts[0]);
        final height = double.parse(parts[1]);
        return width / height;
      }
    } catch (e) {
      // Handle parsing error
    }
    return 16 / 9; // Default aspect ratio
  }

  // Get quality label from resolution
  static String getQualityLabel(String resolution) {
    final height = int.tryParse(resolution.split('x').last) ?? 0;

    if (height >= 2160) return '4K';
    if (height >= 1440) return '1440p';
    if (height >= 1080) return '1080p';
    if (height >= 720) return '720p';
    if (height >= 480) return '480p';
    if (height >= 360) return '360p';
    return 'Unknown';
  }

  // Get quality color based on resolution
  static Color getQualityColor(String resolution) {
    final height = int.tryParse(resolution.split('x').last) ?? 0;

    if (height >= 2160) return Colors.purple; // 4K
    if (height >= 1440) return Colors.blue; // 2K
    if (height >= 1080) return Colors.green; // FHD
    if (height >= 720) return Colors.orange; // HD
    if (height >= 480) return Colors.yellow; // SD
    return Colors.grey; // Lower quality
  }

  // Calculate progress percentage
  static double calculateProgress(Duration position, Duration duration) {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Clamp value between min and max
  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  // Generate unique tag for video controller
  static String generateControllerTag(String videoPath) {
    return 'video_controller_${videoPath.hashCode}';
  }

  // Check if device supports picture-in-picture
  static bool supportsPictureInPicture() {
    // This would need platform-specific implementation
    // For now, return false as a placeholder
    return false;
  }

  // Get video codec from file (simplified)
  static String getVideoCodec(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.mp4':
      case '.m4v':
        return 'H.264';
      case '.mkv':
        return 'H.264/H.265';
      case '.webm':
        return 'VP8/VP9';
      case '.avi':
        return 'Various';
      default:
        return 'Unknown';
    }
  }

  // Validate video file
  static bool validateVideoFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;
      if (!isVideoFile(filePath)) return false;

      // Check if file is readable
      final stat = file.statSync();
      return stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  // Get video metadata (simplified)
  static Map<String, dynamic> getVideoMetadata(String filePath) {
    return {
      'fileName': getVideoFileName(filePath),
      'fileSize': getFileSize(filePath),
      'codec': getVideoCodec(filePath),
      'extension': path.extension(filePath),
      'path': filePath,
    };
  }

  // Generate playlist from directory
  static List<String> generatePlaylistFromDirectory(String directoryPath) {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return [];

      final files = directory.listSync();
      final videoFiles = files
          .whereType<File>()
          .where((file) => isVideoFile(file.path))
          .map((file) => file.path)
          .toList();

      // Sort files alphabetically
      videoFiles.sort((a, b) => path.basename(a).compareTo(path.basename(b)));

      return videoFiles;
    } catch (e) {
      return [];
    }
  }

  // Create video thumbnail directory
  static Future<void> createThumbnailDirectory(String videoPath) async {
    try {
      final dir = path.dirname(videoPath);
      final thumbnailDir = Directory(path.join(dir, '.thumbnails'));

      if (!thumbnailDir.existsSync()) {
        await thumbnailDir.create(recursive: true);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Get supported video formats
  static List<String> getSupportedVideoFormats() {
    return [
      'mp4',
      'avi',
      'mkv',
      'mov',
      'wmv',
      'flv',
      'webm',
      'm4v',
      '3gp',
      'ts',
      'mts',
      'm2ts',
    ];
  }

  // Check if format is supported
  static bool isFormatSupported(String filePath) {
    final extension = path.extension(filePath).toLowerCase().substring(1);
    return getSupportedVideoFormats().contains(extension);
  }
}
