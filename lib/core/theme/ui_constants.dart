import 'package:flutter/material.dart';

/// Centralized UI constants to reduce code duplication
class UIConstants {
  // Border radius values
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  static const double borderRadiusXXLarge = 24.0;

  // Spacing values
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  // Elevation values
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Common padding values
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacingMedium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacingLarge);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(spacingXLarge);

  // Card specific constants
  static const EdgeInsets cardPadding = EdgeInsets.all(spacingLarge);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: spacingLarge,
    vertical: spacingSmall,
  );

  // Video card specific constants
  static const double videoThumbnailWidth = 110.0;
  static const double videoThumbnailHeight = 82.0;
  static const double videoThumbnailBorderRadius = borderRadiusMedium;

  // Button constants
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spacingXXLarge,
    vertical: spacingLarge,
  );

  // Common border radius
  static BorderRadius get borderRadiusSmallAll =>
      BorderRadius.circular(borderRadiusSmall);
  static BorderRadius get borderRadiusMediumAll =>
      BorderRadius.circular(borderRadiusMedium);
  static BorderRadius get borderRadiusLargeAll =>
      BorderRadius.circular(borderRadiusLarge);
  static BorderRadius get borderRadiusXLargeAll =>
      BorderRadius.circular(borderRadiusXLarge);
  static BorderRadius get borderRadiusXXLargeAll =>
      BorderRadius.circular(borderRadiusXXLarge);

  // Common shapes
  static RoundedRectangleBorder get cardShape =>
      RoundedRectangleBorder(borderRadius: borderRadiusXLargeAll);

  static RoundedRectangleBorder get buttonShape =>
      RoundedRectangleBorder(borderRadius: borderRadiusXLargeAll);

  static RoundedRectangleBorder get dialogShape =>
      RoundedRectangleBorder(borderRadius: borderRadiusXXLargeAll);
}
