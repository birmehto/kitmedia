import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/widgets/common/quality_badge.dart';
import '../models/video_file.dart';
import 'video_metadata_row.dart';
import 'video_thumbnail.dart';

/// Optimized video card for list display with clean design
class UnifiedVideoCard extends StatelessWidget {
  const UnifiedVideoCard({
    required this.video,
    required this.onTap,
    super.key,
    this.onLongPress,
    this.isGridView = false,
  });

  final VideoFile video;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: isGridView ? _buildGridLayout(theme) : _buildListLayout(theme),
      ),
    );
  }

  Widget _buildListLayout(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Hero(
            tag: 'thumbnail_${video.id}',
            child: VideoThumbnail(videoFile: video, width: 110, height: 82),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 12),
                VideoMetadataRow(
                  duration: video.durationString,
                  size: video.sizeString,
                  date: video.lastModified,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QualityBadge(fileSize: video.size),
                    if (onLongPress != null)
                      IconButton.filledTonal(
                        icon: const Icon(Symbols.more_vert_rounded, size: 20),
                        onPressed: onLongPress,
                        tooltip: 'More options',
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Hero(
                    tag: 'thumbnail_${video.id}',
                    child: VideoThumbnail(videoFile: video),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: QualityBadge(fileSize: video.size),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                const Spacer(),
                VideoMetadataRow(
                  duration: video.durationString,
                  size: video.sizeString,
                  isCompact: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      video.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
        letterSpacing: 0.1,
      ),
    );
  }
}
