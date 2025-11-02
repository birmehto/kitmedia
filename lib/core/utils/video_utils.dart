/// Utility functions for video-related operations
class VideoUtils {
  VideoUtils._();

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Format duration in HH:MM:SS or MM:SS format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  /// Get video quality from resolution
  static String getQualityFromResolution(int width, int height) {
    final maxDimension = width > height ? width : height;

    if (maxDimension >= 1920) return '1080p';
    if (maxDimension >= 1280) return '720p';
    if (maxDimension >= 854) return '480p';
    if (maxDimension >= 640) return '360p';
    if (maxDimension >= 426) return '240p';
    if (maxDimension >= 256) return '144p';

    return 'Unknown';
  }

  /// Check if video file extension is supported
  static bool isSupportedVideoFormat(String filePath) {
    final supportedExtensions = {
      '.mp4',
      '.avi',
      '.mov',
      '.mkv',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.3gp',
    };

    final extension = filePath.toLowerCase().split('.').last;
    return supportedExtensions.contains('.$extension');
  }
}
