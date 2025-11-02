import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/utils/video_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/video_player_controller.dart';

class EnhancedVideoControls extends StatelessWidget {
  const EnhancedVideoControls({
    required this.videoTitle,
    this.videoPath,
    super.key,
  });

  final String videoTitle;
  final String? videoPath;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GetX<VideoPlayerController>(
      builder: (controller) {
        if (!controller.isInitialized ||
            controller.videoPlayerController == null) {
          return const SizedBox.shrink();
        }

        return AnimatedOpacity(
          opacity: controller.controlsAnimation.value,
          duration: const Duration(milliseconds: 200),
          child: controller.isControlsVisible
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _TopBar(
                          title: videoTitle,
                          path: videoPath,
                          color: color,
                        ),
                        const Spacer(),
                        _CenterControls(color: color),
                        const Spacer(),
                        _BottomBar(color: color),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

// ---------- TOP BAR ----------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.color, this.path});

  final String title;
  final String? path;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoPlayerController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _circleBtn(
            icon: Symbols.arrow_back_ios_new_rounded,
            onTap: AppRoutes.goBack,
            color: color,
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildTitle(context, controller)),
          const SizedBox(width: 16),
          _circleBtn(
            icon: controller.isFullScreen
                ? Symbols.fullscreen_exit_rounded
                : Symbols.fullscreen_rounded,
            onTap: controller.toggleFullScreen,
            color: color,
          ),
          const SizedBox(width: 8),
          _menuBtn(color),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext ctx, VideoPlayerController c) {
    final theme = Theme.of(ctx);
    final info = c.videoPlayerController?.value;
    final res = info == null
        ? ''
        : '${info.size.width.toInt()}×${info.size.height.toInt()}';
    final dur = info == null ? '' : VideoUtils.formatDuration(info.duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (path != null)
          Text(
            '$res • $dur',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white12,
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _menuBtn(Color color) {
    return PopupMenuButton<String>(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Symbols.more_vert_rounded, color: color),
      onSelected: (v) => v == 'info' ? _showInfo() : null,
      itemBuilder: (ctx) => [
        _item('info', Symbols.info_rounded, 'Info', color),
        _item('share', Symbols.share_rounded, 'Share', color),
      ],
    );
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String text,
    Color color,
  ) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );

  void _showInfo() {
    final c = Get.find<VideoPlayerController>();
    final v = c.videoPlayerController?.value;
    if (v == null) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Video Info',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              'Resolution',
              '${v.size.width.toInt()}×${v.size.height.toInt()}',
            ),
            _row('Duration', VideoUtils.formatDuration(v.duration)),
            _row('Aspect', v.aspectRatio.toStringAsFixed(2)),
            if (path != null) _row('Path', path!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Close', style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text('$k:', style: const TextStyle(color: Colors.white54)),
        ),
        Expanded(
          child: Text(v, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ---------- CENTER ----------
class _CenterControls extends StatelessWidget {
  const _CenterControls({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VideoPlayerController>();
    final v = c.videoPlayerController;
    if (v == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: v,
      builder: (_, value, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iconBtn(Symbols.replay_10_rounded, c.seekBackward),
          _playPause(value.isPlaying, c.togglePlayPause),
          _iconBtn(Symbols.forward_10_rounded, c.seekForward),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    ),
  );

  Widget _playPause(bool playing, VoidCallback toggle) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      toggle();
    },
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: playing ? Colors.white24 : Colors.white10,
        border: Border.all(color: Colors.white38, width: 1.5),
      ),
      child: Icon(
        playing ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
        color: Colors.white,
        size: 40,
      ),
    ),
  );
}

// ---------- BOTTOM ----------
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VideoPlayerController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _progress(c),
          const SizedBox(height: 14),
          _actionButtons(c, context),
        ],
      ),
    );
  }

  Widget _progress(VideoPlayerController c) => ValueListenableBuilder(
    valueListenable: c.videoPlayerController!,
    builder: (_, value, _) {
      final pos = value.position;
      final dur = value.duration;
      final ratio = dur.inMilliseconds > 0
          ? pos.inMilliseconds / dur.inMilliseconds
          : 0.0;

      return Column(
        children: [
          Slider(
            // ignore: deprecated_member_use
            year2023: false,
            value: ratio,
            onChanged: (v) => c.seekTo(
              Duration(milliseconds: (v * dur.inMilliseconds).round()),
            ),
            activeColor: color,
            inactiveColor: Colors.white30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                VideoUtils.formatDuration(pos),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '${c.playbackSpeed}×',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                VideoUtils.formatDuration(dur),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      );
    },
  );

  Widget _actionButtons(VideoPlayerController c, BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _control(
          Symbols.volume_up_rounded,
          c.toggleVolumeSlider,
          c.showVolumeSlider,
        ),
        _control(
          Symbols.brightness_6_rounded,
          c.toggleBrightnessSlider,
          c.showBrightnessSlider,
        ),
        _control(
          Symbols.speed_rounded,
          c.toggleSpeedSelector,
          c.showSpeedSelector,
        ),
        _control(Symbols.picture_in_picture_rounded, _showPiP, false),
      ],
    );
  }

  Widget _control(IconData icon, VoidCallback onTap, bool active) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.6) : Colors.white30,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: active ? color : Colors.white, size: 22),
        ),
      ),
    );
  }

  void _showPiP() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Picture in Picture',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'PiP mode not supported on this device.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
