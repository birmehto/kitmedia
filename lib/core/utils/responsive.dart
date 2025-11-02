import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 650;
  static const double tabletBreakpoint = 1100;
  static const double desktopBreakpoint = 1400;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint &&
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    }
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive grid count
  static int getGridCount(
    BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 2,
      desktop: desktop ?? mobile * 3,
      largeDesktop: largeDesktop ?? mobile * 4,
    );
  }

  /// Get responsive padding
  static EdgeInsets getPadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return value(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );
  }

  // Legacy methods for backward compatibility
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getScreenPadding(BuildContext context) =>
      getPadding(context);

  static int getGridCrossAxisCount(BuildContext context) =>
      getGridCount(context);

  /// Get responsive font size
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// Get responsive spacing
  static double getSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Get screen size
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  /// Get device pixel ratio
  static double getPixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;
}
