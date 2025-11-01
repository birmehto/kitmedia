import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

/// Reusable expressive loader for your app.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color, this.size = 48, this.message});

  final Color? color;
  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExpressiveLoadingIndicator(
              color: color ?? colorScheme.primary,
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
                maxWidth: size,
                maxHeight: size,
              ),
              polygons: [
                MaterialShapes.softBurst,
                MaterialShapes.pill,
                MaterialShapes.pentagon,
              ],
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
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
