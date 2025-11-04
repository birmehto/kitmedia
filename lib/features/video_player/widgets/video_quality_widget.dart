import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class VideoQualityWidget extends StatelessWidget {
  const VideoQualityWidget({
    required this.qualities,
    required this.currentQuality,
    required this.onQualityChanged,
    super.key,
  });

  final List<VideoQuality> qualities;
  final VideoQuality? currentQuality;
  final ValueChanged<VideoQuality> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Symbols.hd_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // Quality options
          if (qualities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.video_settings_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No quality options available',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            ...qualities.map((quality) => _buildQualityTile(quality)),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQualityTile(VideoQuality quality) {
    final isSelected = currentQuality?.resolution == quality.resolution;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getQualityColor(quality.resolution).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getQualityColor(
                quality.resolution,
              ).withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            quality.label,
            style: TextStyle(
              color: _getQualityColor(quality.resolution),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          quality.resolution,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: quality.bitrate != null
            ? Text(
                '${(quality.bitrate! / 1000000).toStringAsFixed(1)} Mbps',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )
            : null,
        trailing: isSelected
            ? const Icon(Symbols.check_circle_rounded, color: Colors.white)
            : null,
        onTap: () {
          onQualityChanged(quality);
          Get.back();
        },
      ),
    );
  }

  Color _getQualityColor(String resolution) {
    final height = int.tryParse(resolution.split('x').last) ?? 0;

    if (height >= 2160) return Colors.purple; // 4K
    if (height >= 1440) return Colors.blue; // 2K
    if (height >= 1080) return Colors.green; // FHD
    if (height >= 720) return Colors.orange; // HD
    if (height >= 480) return Colors.yellow; // SD
    return Colors.grey; // Lower quality
  }
}

class VideoQuality {
  const VideoQuality({
    required this.resolution,
    required this.label,
    required this.url,
    this.bitrate,
  });

  final String resolution; // e.g., "1920x1080"
  final String label; // e.g., "1080p"
  final String url; // Video URL for this quality
  final int? bitrate; // Bitrate in bps

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoQuality &&
          runtimeType == other.runtimeType &&
          resolution == other.resolution &&
          url == other.url;

  @override
  int get hashCode => resolution.hashCode ^ url.hashCode;
}

// Quality detector utility
class VideoQualityDetector {
  static List<VideoQuality> detectQualities(String basePath) {
    // This is a simplified implementation
    // In a real app, you might detect different quality files
    // or use adaptive streaming manifests

    final qualities = <VideoQuality>[];

    // Check for common quality variants
    final qualityVariants = [
      {'label': '4K', 'resolution': '3840x2160', 'suffix': '_4k'},
      {'label': '1440p', 'resolution': '2560x1440', 'suffix': '_1440p'},
      {'label': '1080p', 'resolution': '1920x1080', 'suffix': '_1080p'},
      {'label': '720p', 'resolution': '1280x720', 'suffix': '_720p'},
      {'label': '480p', 'resolution': '854x480', 'suffix': '_480p'},
      {'label': '360p', 'resolution': '640x360', 'suffix': '_360p'},
    ];

    for (final variant in qualityVariants) {
      basePath.replaceAll('.mp4', '${variant['suffix']}.mp4');

      // In a real implementation, you'd check if the file exists
      // For now, we'll just add the original quality
      if (variant['label'] == '1080p') {
        qualities.add(
          VideoQuality(
            resolution: variant['resolution']!,
            label: variant['label']!,
            url: basePath,
            bitrate: 5000000, // 5 Mbps
          ),
        );
      }
    }

    return qualities;
  }
}
