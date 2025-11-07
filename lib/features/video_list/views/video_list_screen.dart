import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/ui_constants.dart';

import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../../../core/widgets/common/unified_video_card.dart';
import '../../../routes/app_routes.dart';
import '../controllers/video_controller.dart';
import '../models/video_file.dart';
import '../widgets/video_details_dialog.dart';
import '../widgets/video_options_sheet.dart';

class VideoListScreen extends StatelessWidget {
  VideoListScreen({super.key});

  final VideoController _controller = Get.find<VideoController>();
  final RxBool _isSearching = false.obs;

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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Symbols.video_library_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
              fill: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'app_name'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(
                  () => Text(
                    '${_controller.filteredVideos.length} videos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
          () => IconButton(
            icon: Icon(
              _isSearching.value
                  ? Symbols.search_off_rounded
                  : Symbols.search_rounded,
            ),
            onPressed: () => _toggleSearch(context),
          ),
        ),
        IconButton(
          icon: const Icon(Symbols.settings_rounded),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
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
          () => AnimatedSize(
            duration: UIConstants.animationMedium,
            curve: Curves.easeInOut,
            child: _isSearching.value
                ? _buildSearchBar(context)
                : const SizedBox.shrink(),
          ),
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
        UIConstants.spacingMedium,
      ),
      child: TextField(
        autofocus: true,
        onChanged: _controller.updateSearchQuery,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'search_videos'.tr,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Symbols.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: Obx(
            () => _controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Symbols.clear_rounded),
                    onPressed: _controller.clearSearch,
                    color: theme.colorScheme.error,
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.borderRadiusXXLarge,
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.borderRadiusXXLarge,
            ),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.borderRadiusXXLarge,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingLarge,
            vertical: UIConstants.spacingMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshFab() {
    return Obx(
      () => AnimatedScale(
        scale: _controller.isLoading ? 0.0 : 1.0,
        duration: UIConstants.animationMedium,
        child: _controller.isLoading
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: _controller.refresh,
                child: const Icon(Symbols.refresh_rounded),
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, UIConstants.spacingSmall, 0, 100),
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
    _isSearching.value = !_isSearching.value;
    if (!_isSearching.value) {
      _controller.clearSearch();
    }
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
