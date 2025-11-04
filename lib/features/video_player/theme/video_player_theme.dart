import 'package:flutter/material.dart';

class VideoPlayerTheme {
  static const Color primaryColor = Colors.white;
  static const Color secondaryColor = Colors.white70;
  static const Color accentColor = Colors.blue;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  // Background colors
  static const Color backgroundColor = Colors.black;
  static const Color overlayColor = Colors.black54;
  static const Color controlsBackground = Colors.black87;

  // Control colors
  static const Color controlsActive = Colors.white;
  static const Color controlsInactive = Colors.white54;
  static const Color progressActive = Colors.white;
  static const Color progressInactive = Colors.white30;

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    color: primaryColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: secondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle captionStyle = TextStyle(
    color: secondaryColor,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle buttonStyle = TextStyle(
    color: primaryColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Button themes
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: backgroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
  );

  // Container decorations
  static BoxDecoration get controlsDecoration => BoxDecoration(
    color: controlsBackground,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration get overlayDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundColor.withValues(alpha: 0.7),
        Colors.transparent,
        Colors.transparent,
        backgroundColor.withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ),
  );

  static BoxDecoration get modalDecoration => const BoxDecoration(
    color: controlsBackground,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  // Icon themes
  static const double iconSizeSmall = 20;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;

  // Spacing
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;

  // Border radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Opacity values
  static const double opacityDisabled = 0.3;
  static const double opacityMedium = 0.5;
  static const double opacityHigh = 0.8;

  // Slider theme
  static SliderThemeData get sliderTheme => const SliderThemeData(
    activeTrackColor: progressActive,
    inactiveTrackColor: progressInactive,
    thumbColor: primaryColor,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
    trackHeight: 4,
  );

  // Quality colors
  static const Map<String, Color> qualityColors = {
    '4K': Colors.purple,
    '1440p': Colors.blue,
    '1080p': Colors.green,
    '720p': Colors.orange,
    '480p': Colors.yellow,
    '360p': Colors.grey,
  };

  // Status colors
  static const Color loadingColor = primaryColor;
  static const Color bufferingColor = warningColor;
  static const Color playingColor = successColor;
  static const Color pausedColor = secondaryColor;

  // Gesture feedback
  static BoxDecoration get gestureFeedbackDecoration => BoxDecoration(
    color: backgroundColor.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(radiusMedium),
  );

  // Error theme
  static BoxDecoration get errorDecoration => BoxDecoration(
    color: errorColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: errorColor.withValues(alpha: 0.3)),
  );

  // Success theme
  static BoxDecoration get successDecoration => BoxDecoration(
    color: successColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: successColor.withValues(alpha: 0.3)),
  );

  // Warning theme
  static BoxDecoration get warningDecoration => BoxDecoration(
    color: warningColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: warningColor.withValues(alpha: 0.3)),
  );

  // Get theme color by name
  static Color getThemeColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
        return primaryColor;
      case 'secondary':
        return secondaryColor;
      case 'accent':
        return accentColor;
      case 'error':
        return errorColor;
      case 'success':
        return successColor;
      case 'warning':
        return warningColor;
      case 'background':
        return backgroundColor;
      default:
        return primaryColor;
    }
  }

  // Get quality color
  static Color getQualityColor(String quality) {
    return qualityColors[quality] ?? Colors.grey;
  }

  // Create custom button style
  static ButtonStyle createButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryColor,
      foregroundColor: foregroundColor ?? VideoPlayerTheme.backgroundColor,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(25),
      ),
    );
  }

  // Create custom container decoration
  static BoxDecoration createContainerDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusMedium),
      border: border,
      gradient: gradient,
    );
  }
}
