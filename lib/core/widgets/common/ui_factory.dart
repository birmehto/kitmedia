import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../theme/ui_constants.dart';
import 'loading_indicator.dart';

/// Factory class for creating common UI components with consistent styling
class UIFactory {
  /// Creates a metadata chip with icon and text
  static Widget buildMetadataChip({
    required IconData icon,
    required String text,
    required ThemeData theme,
    double iconSize = UIConstants.iconSizeSmall,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: UIConstants.borderRadiusMediumAll,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color:
                iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          Text(
            text,
            style:
                textStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
          ),
        ],
      ),
    );
  }

  /// Creates a video thumbnail placeholder
  static Widget buildVideoPlaceholder({
    required ThemeData theme,
    double width = UIConstants.videoThumbnailWidth,
    double height = UIConstants.videoThumbnailHeight,
    String? message,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          UIConstants.videoThumbnailBorderRadius,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.video_file_rounded,
              size: width > 80
                  ? UIConstants.iconSizeXLarge
                  : UIConstants.iconSizeLarge,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            if (message != null && width > 80) ...[
              const SizedBox(height: UIConstants.spacingSmall),
              Text(
                message,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a play button overlay
  static Widget buildPlayOverlay({
    required ThemeData theme,
    double size = UIConstants.iconSizeLarge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          size > 20 ? UIConstants.spacingMedium : UIConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: UIConstants.elevationHigh,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Symbols.play_arrow_rounded,
          color: theme.colorScheme.primary,
          size: size,
          fill: 1,
        ),
      ),
    );
  }

  /// Creates a duration badge
  static Widget buildDurationBadge({
    required String duration,
    required ThemeData theme,
    double fontSize = 11,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.scrim.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Text(
        duration,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  /// Creates a gradient overlay
  static Widget buildGradientOverlay({
    required ThemeData theme,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    List<double> stops = const [0.6, 1.0],
    double opacity = 0.3,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            Colors.transparent,
            theme.colorScheme.scrim.withValues(alpha: opacity),
          ],
          stops: stops,
        ),
      ),
    );
  }

  /// Creates a loading shimmer effect
  static Widget buildShimmerPlaceholder({
    required double width,
    required double height,
    double borderRadius = UIConstants.borderRadiusMedium,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: SizedBox(
          width: UIConstants.iconSizeLarge,
          height: UIConstants.iconSizeLarge,
          child: LoadingIndicator(
            // strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Creates a consistent card wrapper
  static Widget buildCard({
    required Widget child,
    required ThemeData theme,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? UIConstants.elevationLow,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      margin: margin ?? UIConstants.cardMargin,
      shape: UIConstants.cardShape,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: UIConstants.borderRadiusXLargeAll,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: padding ?? UIConstants.cardPadding,
          child: child,
        ),
      ),
    );
  }
}
