import 'package:flutter/material.dart';

import '../models/video_file.dart';

class VideoDetailsDialog extends StatelessWidget {
  const VideoDetailsDialog({required this.video, super.key});

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
