import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../features/video_list/models/video_file.dart';
import '../../../features/video_list/widgets/video_metadata_row.dart';
import '../../../features/video_list/widgets/video_thumbnail.dart';
import '../../theme/ui_constants.dart';
import 'quality_badge.dart';
import 'ui_factory.dart';

/// Unified video card that can display in both list and grid layouts
class UnifiedVideoCard extends StatelessWidget {
  const UnifiedVideoCard({
    required this.video,
    required this.onTap,
    super.key,
    this.onLongPress,
    this.layout = VideoCardLayout.list,
    this.showMetadata = true,
    this.showQualityBadge = true,
  });

  final VideoFile video;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VideoCardLayout layout;
  final bool showMetadata;
  final bool showQualityBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UIFactory.buildCard(
      theme: theme,
      onTap: onTap,
      onLongPress: onLongPress,
      child: switch (layout) {
        VideoCardLayout.list => _buildListLayout(theme),
        VideoCardLayout.grid => _buildGridLayout(theme),
        VideoCardLayout.compact => _buildCompactLayout(theme),
      },
    );
  }

  Widget _buildListLayout(ThemeData theme) {
    return Row(
      children: [
        Hero(
          tag: 'thumbnail_${video.id}',
          child: VideoThumbnail(
            videoFile: video,
            width: UIConstants.videoThumbnailWidth,
            height: UIConstants.videoThumbnailHeight,
          ),
        ),
        const SizedBox(width: UIConstants.spacingXLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(theme),
              if (showMetadata) ...[
                const SizedBox(height: UIConstants.spacingMedium),
                VideoMetadataRow(
                  size: video.sizeString,
                  date: video.lastModified,
                ),
              ],
              const SizedBox(height: UIConstants.spacingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showQualityBadge) QualityBadge(fileSize: video.size),
                  if (onLongPress != null)
                    IconButton.filledTonal(
                      icon: const Icon(
                        Symbols.more_vert_rounded,
                        size: UIConstants.iconSizeMedium,
                      ),
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
                  padding: const EdgeInsets.all(UIConstants.spacingMedium),
                  child: Hero(
                    tag: 'thumbnail_${video.id}',
                    child: VideoThumbnail(videoFile: video),
                  ),
                ),
              ),
              if (showQualityBadge)
                Positioned(
                  top: UIConstants.spacingLarge,
                  right: UIConstants.spacingLarge,
                  child: QualityBadge(fileSize: video.size),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.spacingLarge,
              UIConstants.spacingMedium,
              UIConstants.spacingLarge,
              UIConstants.spacingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                if (showMetadata) ...[
                  const Spacer(),
                  VideoMetadataRow(
                    size: video.sizeString,
                    isCompact: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(ThemeData theme) {
    return Row(
      children: [
        VideoThumbnail(
          videoFile: video,
          width: 80,
          height: 60,
          borderRadius: UIConstants.borderRadiusSmall,
        ),
        const SizedBox(width: UIConstants.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(theme, maxLines: 1),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                video.path,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showMetadata) ...[
                const SizedBox(height: UIConstants.spacingSmall),
                Row(
                  children: [
                    UIFactory.buildMetadataChip(
                      icon: Symbols.storage,
                      text: video.sizeString,
                      theme: theme,
                      iconSize: 14,
                    ),
                    if (video.duration != null) ...[
                      const SizedBox(width: UIConstants.spacingMedium),
                      UIFactory.buildMetadataChip(
                        icon: Symbols.access_time,
                        text: video.durationString,
                        theme: theme,
                        iconSize: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        UIFactory.buildPlayOverlay(theme: theme, onTap: onTap),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme, {int maxLines = 2}) {
    return Text(
      video.name,
      maxLines: maxLines,
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

enum VideoCardLayout { list, grid, compact }
