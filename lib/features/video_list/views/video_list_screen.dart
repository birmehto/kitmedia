import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/ui_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../../../core/widgets/common/unified_video_card.dart';
import '../../../routes/app_routes.dart';
import '../controllers/video_controller.dart';
import '../models/video_file.dart';
import '../widgets/search_dialog.dart';
import '../widgets/video_details_dialog.dart';
import '../widgets/video_options_sheet.dart';

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  VideoController get _controller => Get.find<VideoController>();

  @override
  Widget build(BuildContext context) {
    // Initialize scanning on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.videos.isEmpty && !_controller.isLoading) {
        _controller.scanVideos();
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
      floatingActionButton: _buildRefreshFab(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 3,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      title: Row(
        children: [
          Hero(
            tag: 'app_icon',
            child: Container(
              padding: const EdgeInsets.all(UIConstants.spacingMedium),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: UIConstants.borderRadiusLargeAll,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: UIConstants.elevationHigh,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Symbols.video_library_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
                fill: 1,
              ),
            ),
          ),
          const SizedBox(width: UIConstants.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_name'.tr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Obx(
                  () => Text(
                    '${_controller.filteredVideos.length} videos',
                    key: ValueKey(_controller.filteredVideos.length),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => IconButton.filledTonal(
            key: ValueKey(_controller.searchQuery.isEmpty),
            icon: Icon(
              _controller.searchQuery.isEmpty
                  ? Symbols.search_rounded
                  : Symbols.search_off_rounded,
              fill: _controller.searchQuery.isEmpty ? 0 : 1,
            ),
            onPressed: () => _toggleSearch(context),
            tooltip: 'search_videos'.tr,
          ),
        ),
        const SizedBox(width: UIConstants.spacingSmall),
        IconButton.outlined(
          icon: const Icon(Symbols.settings_rounded),
          onPressed: () => Get.toNamed(AppRoutes.settings),
          tooltip: 'Settings',
        ),
        const SizedBox(width: UIConstants.spacingSmall),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return LoadingIndicator(message: 'loading'.tr);
    }

    if (_controller.errorMessage.isNotEmpty) {
      return _buildErrorState(_controller.errorMessage);
    }

    return Column(
      children: [
        Obx(
          () => _controller.searchQuery.isNotEmpty
              ? _buildSearchBar(context)
              : const SizedBox.shrink(),
        ),
        Expanded(child: _buildVideoList(_controller.filteredVideos)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        UIConstants.spacingXLarge,
        UIConstants.spacingMedium,
        UIConstants.spacingXLarge,
        UIConstants.spacingSmall,
      ),
      child: SearchBar(
        hintText: 'search_videos'.tr,
        leading: Icon(
          Symbols.search_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        trailing: [
          IconButton.filledTonal(
            icon: const Icon(Symbols.clear_rounded),
            onPressed: _controller.clearSearch,
            visualDensity: VisualDensity.compact,
          ),
        ],
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return UIConstants.elevationHigh;
          }
          return UIConstants.elevationMedium;
        }),
        shadowColor: WidgetStateProperty.all(
          theme.colorScheme.shadow.withValues(alpha: 0.15),
        ),
        surfaceTintColor: WidgetStateProperty.all(
          theme.colorScheme.surfaceTint,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.borderRadiusXXLarge,
            ),
          ),
        ),
        onChanged: _controller.updateSearchQuery,
      ),
    );
  }

  Widget _buildRefreshFab() {
    return Obx(
      () => AnimatedScale(
        scale: _controller.isLoading ? 0.0 : 1.0,
        duration: UIConstants.animationMedium,
        curve: Curves.elasticOut,
        child: FloatingActionButton.extended(
          onPressed: _controller.refresh,
          tooltip: 'Refresh videos',
          icon: Icon(
            Symbols.refresh_rounded,
            fill: _controller.isLoading ? 1 : 0,
          ),
          label: const Text('Refresh'),
          elevation: UIConstants.elevationHigh,
          highlightElevation: UIConstants.elevationHigh * 2,
        ),
      ),
    );
  }

  Widget _buildVideoList(List<VideoFile> videos) {
    if (videos.isEmpty) {
      return EmptyState(
        icon: Symbols.video_library,
        title: 'no_videos_found'.tr,
        subtitle: 'Try refreshing or check your storage permissions',
        action: FilledButton.tonalIcon(
          onPressed: _controller.refresh,
          icon: const Icon(Symbols.refresh_rounded),
          label: Text('refresh'.tr),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isGridView =
            Responsive.isTablet(context) || Responsive.isDesktop(context);

        if (isGridView) {
          return GridView.builder(
            padding: Responsive.getPadding(
              context,
            ).copyWith(bottom: 120, top: UIConstants.spacingSmall),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.getGridCount(
                context,
                tablet: 2,
                desktop: 3,
              ),
              childAspectRatio: 1.2,
              crossAxisSpacing: UIConstants.spacingMedium,
              mainAxisSpacing: UIConstants.spacingMedium,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return UnifiedVideoCard(
                video: video,
                onTap: () => _playVideo(video),
                onLongPress: () => _showVideoOptions(context, video),
                layout: VideoCardLayout.grid,
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            0,
            UIConstants.spacingSmall,
            0,
            120,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return UnifiedVideoCard(
              video: video,
              onTap: () => _playVideo(video),
              onLongPress: () => _showVideoOptions(context, video),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return EmptyState(
      icon: Symbols.error_outline,
      title: 'error_occurred'.tr,
      subtitle: error,
      action: FilledButton.icon(
        onPressed: _controller.refresh,
        icon: const Icon(Symbols.refresh_rounded),
        label: Text('retry'.tr),
      ),
    );
  }

  void _toggleSearch(BuildContext context) {
    if (_controller.searchQuery.isEmpty) {
      _showSearchDialog(context);
    } else {
      _controller.clearSearch();
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SearchDialog(controller: _controller),
    );
  }

  void _showVideoOptions(BuildContext context, VideoFile video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.borderRadiusXXLarge),
        ),
      ),
      builder: (context) => VideoOptionsSheet(
        video: video,
        onPlay: () => _playVideo(video),
        onShowDetails: () => _showVideoDetails(context, video),
        onDelete: () => _deleteVideo(video),
      ),
    );
  }

  void _showVideoDetails(BuildContext context, VideoFile video) {
    showDialog(
      context: context,
      builder: (context) => VideoDetailsDialog(video: video),
    );
  }

  void _playVideo(VideoFile video) {
    AppRoutes.navigateToVideoPlayer(
      videoPath: video.path,
      videoTitle: video.name,
    );
  }

  void _deleteVideo(VideoFile video) {
    _controller.deleteVideo(video);
  }
}
