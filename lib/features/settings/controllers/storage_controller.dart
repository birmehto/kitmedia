import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/storage/local_storage.dart';

class StorageController extends GetxController {
  final RxBool _cacheEnabled = true.obs;
  final RxInt _maxCacheSize = 500.obs; // MB
  final RxBool _autoDeleteEnabled = false.obs;
  final RxInt _autoDeleteDays = 7.obs;
  final RxString _currentCacheSize = '0 MB'.obs;
  final RxString _availableStorage = '0 GB'.obs;

  // Getters
  bool get cacheEnabled => _cacheEnabled.value;
  int get maxCacheSize => _maxCacheSize.value;
  bool get autoDeleteEnabled => _autoDeleteEnabled.value;
  int get autoDeleteDays => _autoDeleteDays.value;
  String get currentCacheSize => _currentCacheSize.value;
  String get availableStorage => _availableStorage.value;

  final List<int> availableCacheSizes = [100, 250, 500, 1000, 2000]; // MB
  final List<int> availableDeleteDays = [1, 3, 7, 14, 30];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _updateStorageInfo();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.to;

    _cacheEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.cacheEnabled) ?? true;
    _maxCacheSize.value =
        storage.getUserPreference<int>(StorageKeys.maxCacheSize) ?? 500;
    _autoDeleteEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.autoDelete) ?? false;
    _autoDeleteDays.value =
        storage.getUserPreference<int>(StorageKeys.autoDeleteDays) ?? 7;

    update();
  }

  Future<void> _updateStorageInfo() async {
    try {
      // Get cache manager cache size
      final cacheManager = DefaultCacheManager();
      final cacheSize = await _getCacheManagerSize(cacheManager);

      // Get temp directory size
      final tempDir = await getTemporaryDirectory();
      final tempSize = await _getDirectorySize(tempDir);

      final totalCacheSize = cacheSize + tempSize;
      _currentCacheSize.value = _formatBytes(totalCacheSize);

      // Get available storage info
      await _getStorageInfo();

      update();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<int> _getCacheManagerSize(CacheManager cacheManager) async {
    try {
      // Simplified cache size calculation
      // In a real implementation, you would iterate through cache files
      return 0; // Placeholder
    } catch (e) {
      return 0;
    }
  }

  Future<void> _getStorageInfo() async {
    try {
      if (Platform.isAndroid) {
        // Get storage info for Android
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final stat = externalDir.statSync();
          final availableBytes = stat.size;
          _availableStorage.value = _formatBytes(availableBytes);
        } else {
          _availableStorage.value = 'Unknown';
        }
      } else if (Platform.isIOS) {
        // For iOS, we can't get exact storage info due to sandboxing
        _availableStorage.value = 'iOS Storage';
      } else {
        _availableStorage.value = 'Unknown Platform';
      }
    } catch (e) {
      _availableStorage.value = 'Unknown';
    }
  }

  Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> setCacheEnabled(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.cacheEnabled,
      enabled,
    );
    _cacheEnabled.value = enabled;
    update();
  }

  Future<void> setMaxCacheSize(int size) async {
    await StorageService.to.saveUserPreference(StorageKeys.maxCacheSize, size);
    _maxCacheSize.value = size;
    update();
  }

  Future<void> setAutoDelete(bool enabled) async {
    await StorageService.to.saveUserPreference(StorageKeys.autoDelete, enabled);
    _autoDeleteEnabled.value = enabled;
    update();
  }

  Future<void> setAutoDeleteDays(int days) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.autoDeleteDays,
      days,
    );
    _autoDeleteDays.value = days;
    update();
  }

  Future<void> clearCache() async {
    try {
      // Clear cache manager cache
      final cacheManager = DefaultCacheManager();
      await cacheManager.emptyCache();

      // Clear temp directory
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }

      await _updateStorageInfo();
      Get.snackbar(
        'Cache Cleared',
        'All cached files have been removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cache: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getCacheSizeString(int size) {
    if (size >= 1000) return '${size ~/ 1000} GB';
    return '$size MB';
  }

  String getAutoDeleteString(int days) {
    if (days == 1) return '1 day';
    return '$days days';
  }
}
