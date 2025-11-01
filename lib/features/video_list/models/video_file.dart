import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
class VideoFile {
  const VideoFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
    this.thumbnail,
    this.duration,
  });

  factory VideoFile.fromFile(File file) {
    final stat = file.statSync();
    return VideoFile(
      id: file.path.hashCode.toString(),
      name: file.path.split(Platform.pathSeparator).last,
      path: file.path,
      size: stat.size,
      lastModified: stat.modified,
    );
  }
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime lastModified;
  final String? thumbnail;
  final Duration? duration;

  String get sizeString {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get extension {
    return path.toLowerCase().substring(path.lastIndexOf('.'));
  }

  String get durationString {
    if (duration == null) return '';

    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  VideoFile copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    DateTime? lastModified,
    String? thumbnail,
    Duration? duration,
  }) {
    return VideoFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
