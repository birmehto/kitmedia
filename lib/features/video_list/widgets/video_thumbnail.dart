import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../../../core/utils/logger.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../models/video_file.dart';

class VideoThumbnail extends StatefulWidget {
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

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _cachedThumbnail;
  bool _isLoading = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 1;

  @override
  bool get wantKeepAlive => _cachedThumbnail != null;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile.path != widget.videoFile.path) {
      _cachedThumbnail = null;
      _hasError = false;
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final thumbnail = await _getCachedThumbnail();
      if (mounted) {
        setState(() {
          _cachedThumbnail = thumbnail;
          _hasError = thumbnail == null;
          _isLoading = false;
        });

        // Retry once if failed and haven't exceeded max retries
        if (thumbnail == null && _retryCount < _maxRetries) {
          _retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) _loadThumbnail();
        }
      }
    } catch (e) {
      appLog('Load thumbnail error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cachedThumbnail = null;
    super.dispose();
  }

  Future<Uint8List?> _getCachedThumbnail() async {
    final videoPath = widget.videoFile.path;
    final cacheKey = 'thumb_${videoPath.hashCode}';

    try {
      // Check cache first
      final cacheFile = await DefaultCacheManager().getFileFromCache(cacheKey);
      if (cacheFile?.file.existsSync() ?? false) {
        return await cacheFile!.file.readAsBytes();
      }
    } catch (e) {
      appLog('Cache read error: $e');
    }

    // Verify file exists
    final file = File(videoPath);
    if (!file.existsSync()) {
      appLog('Video file not found: $videoPath');
      return null;
    }

    // Try to generate thumbnail with multiple fallback strategies
    try {
      // Strategy 1: Try with file:// URI scheme for Android
      final uri = Platform.isAndroid && !videoPath.startsWith('file://')
          ? 'file://$videoPath'
          : videoPath;

      final thumb =
          await vt.VideoThumbnail.thumbnailData(
            video: uri,
            imageFormat: vt.ImageFormat.JPEG,
            maxWidth: (widget.width * 1.5).clamp(100.0, 800.0).toInt(),
            maxHeight: (widget.height * 1.5).clamp(75.0, 600.0).toInt(),
            quality: 70,
            timeMs: 2000,
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              appLog('Thumbnail generation timeout for: $videoPath');
              return null;
            },
          );

      if (thumb != null && thumb.isNotEmpty) {
        // Cache the thumbnail
        try {
          await DefaultCacheManager().putFile(cacheKey, thumb);
        } catch (e) {
          appLog('Cache write error: $e');
        }
        return thumb;
      }
    } catch (e) {
      appLog('Thumbnail generation error for $videoPath: $e');

      // Strategy 2: Try without URI scheme if first attempt failed
      if (Platform.isAndroid && videoPath.startsWith('file://')) {
        try {
          final plainPath = videoPath.replaceFirst('file://', '');
          final thumb = await vt.VideoThumbnail.thumbnailData(
            video: plainPath,
            imageFormat: vt.ImageFormat.JPEG,
            maxWidth: (widget.width * 1.5).clamp(100.0, 800.0).toInt(),
            maxHeight: (widget.height * 1.5).clamp(75.0, 600.0).toInt(),
            quality: 70,
            timeMs: 1000,
          ).timeout(const Duration(seconds: 5));

          if (thumb != null && thumb.isNotEmpty) {
            try {
              await DefaultCacheManager().putFile(cacheKey, thumb);
            } catch (_) {}
            return thumb;
          }
        } catch (e2) {
          appLog('Fallback thumbnail generation failed: $e2');
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
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
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnailContent(theme),
            if (_cachedThumbnail != null) _buildGradient(theme),
            if (_cachedThumbnail != null && widget.videoFile.duration != null)
              _buildDurationBadge(theme),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(ThemeData theme) {
    if (_cachedThumbnail != null) {
      return Image.memory(
        _cachedThumbnail!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildError(theme),
      );
    }

    if (_hasError) {
      return _buildError(theme);
    }

    return _buildError(theme);
  }

  Widget _buildLoadingOverlay() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.3),
      child: _buildLoading(),
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
          child: LoadingIndicator(
            // strokeWidth: 2.5,
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
              size: widget.width > 80 ? 40 : 32,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            if (widget.width > 80) ...[
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
          widget.videoFile.durationString,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.width > 80 ? 11 : 9,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
