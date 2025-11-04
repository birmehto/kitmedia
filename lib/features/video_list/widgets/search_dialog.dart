import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/video_controller.dart';

class SearchDialog extends StatelessWidget {
  const SearchDialog({required this.controller, super.key});

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = TextEditingController(
      text: controller.searchQuery,
    );

    return AlertDialog(
      icon: Icon(
        Symbols.search_rounded,
        size: 32,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'search_videos'.tr,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter video name or path...',
          prefixIcon: Icon(
            Symbols.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        onChanged: controller.updateSearchQuery,
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            controller.clearSearch();
            Navigator.pop(context);
          },
          icon: const Icon(Symbols.clear_rounded),
          label: const Text('Clear'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.check_rounded),
          label: const Text('Done'),
        ),
      ],
    );
  }
}
