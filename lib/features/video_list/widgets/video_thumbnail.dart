import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../../../core/utils/logger.dart';
import '../models/video_file.dart';

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    required this.videoFile,
    this.width = 120,
    this.height = 90,
    this.borderRadius = 12,
    super.key,
  });

  final VideoFile videoFile;
  final double width;
  final double height;
  final double borderRadius;

  String get videoPath => videoFile.path;

  Future<Uint8List?> _getCachedThumbnail() async {
    try {
      final cacheKey = 'thumb_${videoPath.hashCode}';
      final cacheFile = await DefaultCacheManager().getFileFromCache(cacheKey);

      if (cacheFile?.file.existsSync() ?? false) {
        return await cacheFile!.file.readAsBytes();
      }

      if (!File(videoPath).existsSync()) return null;

      final thumb = await vt.VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: vt.ImageFormat.JPEG,
        maxWidth: (width * 1.5).clamp(100.0, 800.0).toInt(),
        maxHeight: (height * 1.5).clamp(75.0, 600.0).toInt(),
        quality: 70,
        timeMs: 2000,
      ).timeout(const Duration(seconds: 8));

      if (thumb != null) {
        await DefaultCacheManager().putFile(cacheKey, thumb);
      }

      return thumb;
    } catch (e) {
      appLog('Thumbnail error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: FutureBuilder<Uint8List?>(
          future: _getCachedThumbnail(),
          builder: (context, snapshot) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnailContent(snapshot, theme),
                _buildGradient(theme),
                _buildPlayOverlay(theme),
                if (videoFile.duration != null) _buildDurationBadge(theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(
    AsyncSnapshot<Uint8List?> snapshot,
    ThemeData theme,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoading();
    }

    if (snapshot.hasError || snapshot.data == null) {
      return _buildError(theme);
    }

    return Image.memory(
      snapshot.data!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildError(theme),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.video_file_rounded,
              size: width > 80 ? 40 : 32,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            if (width > 80) ...[
              const SizedBox(height: 8),
              Text(
                'No Preview',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGradient(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.colorScheme.scrim.withValues(alpha: 0.3),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildPlayOverlay(ThemeData theme) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(width > 80 ? 10 : 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Symbols.play_arrow_rounded,
          color: theme.colorScheme.primary,
          size: width > 80 ? 24 : 20,
          fill: 1,
        ),
      ),
    );
  }

  Widget _buildDurationBadge(ThemeData theme) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.scrim.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          videoFile.durationString,
          style: TextStyle(
            color: Colors.white,
            fontSize: width > 80 ? 11 : 9,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
