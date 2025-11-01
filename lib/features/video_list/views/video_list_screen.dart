import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../../../routes/app_routes.dart';
import '../controllers/video_controller.dart';
import '../models/video_file.dart';
import '../widgets/unified_video_card.dart';

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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
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
          const SizedBox(width: 16),
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
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: const Icon(Symbols.settings_rounded),
          onPressed: () => Get.toNamed(AppRoutes.settings),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
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
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
          if (states.contains(WidgetState.focused)) return 6;
          return 3;
        }),
        shadowColor: WidgetStateProperty.all(
          theme.colorScheme.shadow.withValues(alpha: 0.15),
        ),
        surfaceTintColor: WidgetStateProperty.all(
          theme.colorScheme.surfaceTint,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onChanged: _controller.updateSearchQuery,
      ),
    );
  }

  Widget _buildRefreshFab() {
    return Obx(
      () => AnimatedScale(
        scale: _controller.isLoading ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: FloatingActionButton.extended(
          onPressed: _controller.refresh,
          tooltip: 'Refresh videos',
          icon: Icon(
            Symbols.refresh_rounded,
            fill: _controller.isLoading ? 1 : 0,
          ),
          label: const Text('Refresh'),
          elevation: 6,
          highlightElevation: 12,
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
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
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
    if (_controller.searchQuery.isEmpty) {
      _showSearchDialog(context);
    } else {
      _controller.clearSearch();
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(controller: _controller),
    );
  }

  void _showVideoOptions(BuildContext context, VideoFile video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _VideoOptionsSheet(
        video: video,
        onPlay: () => _playVideo(video),
        onShowDetails: () => _showVideoDetails(context, video),
      ),
    );
  }

  void _showVideoDetails(BuildContext context, VideoFile video) {
    showDialog(
      context: context,
      builder: (context) => _VideoDetailsDialog(video: video),
    );
  }

  void _playVideo(VideoFile video) {
    AppRoutes.navigateToVideoPlayer(
      videoPath: video.path,
      videoTitle: video.name,
    );
  }
}

// Separate stateless widgets for better performance and reusability
class _SearchDialog extends StatelessWidget {
  const _SearchDialog({required this.controller});

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = TextEditingController(
      text: controller.searchQuery,
    );

    return AlertDialog(
      icon: Icon(
        Symbols.search_rounded,
        size: 32,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'search_videos'.tr,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter video name or path...',
          prefixIcon: Icon(
            Symbols.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        onChanged: controller.updateSearchQuery,
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            controller.clearSearch();
            Navigator.pop(context);
          },
          icon: const Icon(Symbols.clear_rounded),
          label: const Text('Clear'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.check_rounded),
          label: const Text('Done'),
        ),
      ],
    );
  }
}

class _VideoOptionsSheet extends StatelessWidget {
  const _VideoOptionsSheet({
    required this.video,
    required this.onPlay,
    required this.onShowDetails,
  });

  final VideoFile video;
  final VoidCallback onPlay;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Symbols.video_file_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    video.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Symbols.play_circle_rounded,
            iconColor: theme.colorScheme.primary,
            title: 'video_player'.tr,
            subtitle: 'Start playback',
            onTap: () {
              Navigator.pop(context);
              onPlay();
            },
          ),
          _OptionTile(
            icon: Symbols.info_rounded,
            iconColor: theme.colorScheme.secondary,
            title: 'Video Details',
            subtitle: 'View file information',
            onTap: () {
              Navigator.pop(context);
              onShowDetails();
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Symbols.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}

class _VideoDetailsDialog extends StatelessWidget {
  const _VideoDetailsDialog({required this.video});

  final VideoFile video;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        video.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Path', value: video.path),
          _DetailRow(label: 'Size', value: video.sizeString),
          _DetailRow(label: 'Modified', value: video.lastModified.toString()),
          if (video.duration != null)
            _DetailRow(label: 'Duration', value: video.durationString),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
