import 'package:flutter/foundation.dart';

import 'video_file.dart';

@immutable
class VideoFolder {
  const VideoFolder({
    required this.name,
    required this.path,
    required this.videos,
    this.thumbnail,
  });

  final String name;
  final String path;
  final List<VideoFile> videos;
  final String? thumbnail; // Path to thumbnail image

  int get videoCount => videos.length;

  Duration get totalDuration {
    return videos.fold(
      Duration.zero,
      (total, video) => total + (video.duration ?? Duration.zero),
    );
  }

  int get totalSize {
    return videos.fold(0, (total, video) => total + video.size);
  }

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

  String get totalDurationString {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  DateTime get lastModified {
    if (videos.isEmpty) return DateTime.now();
    return videos
        .map((v) => v.lastModified)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  VideoFolder copyWith({
    String? name,
    String? path,
    List<VideoFile>? videos,
    String? thumbnail,
  }) {
    return VideoFolder(
      name: name ?? this.name,
      path: path ?? this.path,
      videos: videos ?? this.videos,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoFolder && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
