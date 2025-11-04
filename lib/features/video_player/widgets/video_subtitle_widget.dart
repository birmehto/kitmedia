import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoSubtitleWidget extends StatelessWidget {
  const VideoSubtitleWidget({required this.subtitle, super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (subtitle.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SubtitleController extends GetxController {
  final subtitles = <SubtitleEntry>[].obs;
  final currentSubtitle = ''.obs;
  final isEnabled = true.obs;
  final fontSize = 16.0.obs;
  final textColor = Colors.white.obs;
  final backgroundColor = Colors.black.obs;
  final backgroundOpacity = 0.8.obs;

  void loadSubtitles(List<SubtitleEntry> subs) {
    subtitles.value = subs;
  }

  void updateSubtitle(Duration position) {
    if (!isEnabled.value || subtitles.isEmpty) {
      currentSubtitle.value = '';
      return;
    }

    final current = subtitles.firstWhereOrNull(
      (sub) => position >= sub.start && position <= sub.end,
    );

    currentSubtitle.value = current?.text ?? '';
  }

  void setEnabled(bool enabled) => isEnabled.value = enabled;
  void setFontSize(double size) => fontSize.value = size;
  void setTextColor(Color color) => textColor.value = color;
  void setBackgroundColor(Color color) => backgroundColor.value = color;
  void setBackgroundOpacity(double opacity) =>
      backgroundOpacity.value = opacity;
}

class SubtitleEntry {
  const SubtitleEntry({
    required this.start,
    required this.end,
    required this.text,
  });

  final Duration start;
  final Duration end;
  final String text;
}

// SRT Parser utility
class SRTParser {
  static List<SubtitleEntry> parse(String srtContent) {
    final entries = <SubtitleEntry>[];
    final blocks = srtContent.split('\n\n');

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      try {
        // Parse timestamp line (format: 00:00:00,000 --> 00:00:00,000)
        final timestampLine = lines[1];
        final timestamps = timestampLine.split(' --> ');
        if (timestamps.length != 2) continue;

        final start = _parseTimestamp(timestamps[0]);
        final end = _parseTimestamp(timestamps[1]);

        // Join subtitle text lines
        final text = lines.sublist(2).join('\n');

        entries.add(SubtitleEntry(start: start, end: end, text: text));
      } catch (e) {
        // Skip malformed entries
        continue;
      }
    }

    return entries;
  }

  static Duration _parseTimestamp(String timestamp) {
    // Format: 00:00:00,000
    final parts = timestamp.split(':');
    final secondsParts = parts[2].split(',');

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(secondsParts[0]);
    final milliseconds = int.parse(secondsParts[1]);

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
