import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

/// A reusable expressive loader widget styled with Material 3 principles.
///
/// Displays an animated geometric indicator with an optional message.
/// Ideal for full-screen or inline loading states.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 60,
    this.message,
    this.padding = const EdgeInsets.all(24),
  });

  /// Primary color for the loader animation.
  /// Falls back to [Theme.of(context).colorScheme.primary].
  final Color? color;

  /// Size of the loading animation (both width & height).
  final double size;

  /// Optional message shown below the indicator.
  final String? message;

  /// Padding around the loader and message.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final indicatorColor =
        color ??
        (theme.brightness == Brightness.dark
            ? colorScheme.primaryContainer
            : colorScheme.primary);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Loading, please wait...',
              child: ExpressiveLoadingIndicator(
                color: indicatorColor,
                // constraints: BoxConstraints.tightFor(width: size, height: size),
                polygons: [
                  MaterialShapes.softBurst,
                  MaterialShapes.pill,
                  MaterialShapes.pentagon,
                  MaterialShapes.arrow,
                  MaterialShapes.cookie12Sided,
                  MaterialShapes.burst,
                ],
              ),
            ),
            if (message?.isNotEmpty ?? false) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
