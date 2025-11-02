import 'package:flutter/material.dart';

import '../../../core/widgets/common/unified_video_card.dart' as core;
import '../models/video_file.dart';

/// Legacy wrapper - use core/widgets/common/unified_video_card.dart instead
/// This file is kept for backward compatibility
@Deprecated(
  'Use UnifiedVideoCard from core/widgets/common/unified_video_card.dart',
)
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
    // Use the new unified video card from core
    return core.UnifiedVideoCard(
      video: video,
      onTap: onTap,
      onLongPress: onLongPress,
      layout: isGridView
          ? core.VideoCardLayout.grid
          : core.VideoCardLayout.list,
    );
  }
}
