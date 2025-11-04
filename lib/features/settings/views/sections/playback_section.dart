import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../controllers/playback_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class PlaybackSection extends StatelessWidget {
  const PlaybackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Playback',
      icon: Symbols.play_circle_rounded,
      children: [
        // Auto Play
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.play_arrow_rounded,
            title: 'Auto Play',
            subtitle: 'Automatically play videos when opened',
            trailing: Switch(
              value: controller.autoPlayEnabled,
              onChanged: controller.setAutoPlay,
            ),
          ),
        ),

        // Loop Video
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.repeat_rounded,
            title: 'Loop Videos',
            subtitle: 'Repeat videos automatically',
            trailing: Switch(
              value: controller.loopVideoEnabled,
              onChanged: controller.setLoopVideo,
            ),
          ),
        ),

        // Playback Speed
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.speed_rounded,
            title: 'Default Playback Speed',
            subtitle: controller.getSpeedString(controller.playbackSpeed),
            onTap: () => _showSpeedDialog(context, controller),
          ),
        ),

        // Skip Duration
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.fast_forward_rounded,
            title: 'Skip Duration',
            subtitle: controller.getSkipDurationString(controller.skipDuration),
            onTap: () => _showSkipDurationDialog(context, controller),
          ),
        ),

        // Default Volume
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.volume_up_rounded,
            title: 'Default Volume',
            subtitle: '${(controller.defaultVolume * 100).round()}%',
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: controller.defaultVolume,
                onChanged: controller.setDefaultVolume,
              ),
            ),
          ),
        ),

        // Default Brightness
        GetBuilder<PlaybackController>(
          builder: (controller) => SettingsTile(
            icon: Symbols.brightness_6_rounded,
            title: 'Default Brightness',
            subtitle: '${(controller.defaultBrightness * 100).round()}%',
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: controller.defaultBrightness,
                onChanged: controller.setDefaultBrightness,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSpeedDialog(BuildContext context, PlaybackController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableSpeeds.map((speed) {
            return ListTile(
              title: Text(controller.getSpeedString(speed)),
              leading: controller.playbackSpeed == speed
                  ? const Icon(Symbols.check)
                  : null,
              onTap: () {
                controller.setPlaybackSpeed(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSkipDurationDialog(
    BuildContext context,
    PlaybackController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableSkipDurations.map((duration) {
            return ListTile(
              title: Text(controller.getSkipDurationString(duration)),
              leading: controller.skipDuration == duration
                  ? const Icon(Symbols.check)
                  : null,
              onTap: () {
                controller.setSkipDuration(duration);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
