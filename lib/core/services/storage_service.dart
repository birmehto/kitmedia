import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../platform/android_platform.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';

/// Comprehensive storage service that manages both local storage and platform-specific storage
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  // Observable storage statistics
  final RxMap<String, dynamic> _storageStats = <String, dynamic>{}.obs;
  final RxBool _isInitialized = false.obs;
  final RxList<String> _externalDirectories = <String>[].obs;
  final RxInt _availableSpace = 0.obs;
  final RxInt _totalSpace = 0.obs;

  // Getters
  Map<String, dynamic> get storageStats => _storageStats;
  bool get isInitialized => _isInitialized.value;
  List<String> get externalDirectories => _externalDirectories;
  int get availableSpace => _availableSpace.value;
  int get totalSpace => _totalSpace.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  /// Initialize the storage service
  Future<void> initialize() async {
    try {
      // Initialize local storage
      await LocalStorage.initialize();

      // Initialize Android platform if on Android
      if (Platform.isAndroid) {
        await AndroidPlatform.initialize();
        await _loadAndroidStorageInfo();
      }

      // Update storage statistics
      await updateStorageStats();

      _isInitialized.value = true;

      if (kDebugMode) {
        print('StorageService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize StorageService: $e');
      }
      rethrow;
    }
  }

  /// Load Android-specific storage information
  Future<void> _loadAndroidStorageInfo() async {
    if (!Platform.isAndroid) return;

    try {
      // Get external storage directories
      final directories = await AndroidPlatform.getExternalStorageDirectories();
      _externalDirectories.assignAll(directories);

      // Get storage space information
      final available = await AndroidPlatform.getAvailableStorageSpace();
      final total = await AndroidPlatform.getTotalStorageSpace();

      _availableSpace.value = available;
      _totalSpace.value = total;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load Android storage info: $e');
      }
    }
  }

  /// Update storage statistics
  Future<void> updateStorageStats() async {
    try {
      final stats = LocalStorage.getStorageStats();

      if (Platform.isAndroid) {
        stats['android'] = {
          'externalDirectories': _externalDirectories,
          'availableSpace': _availableSpace.value,
          'totalSpace': _totalSpace.value,
          'usedSpace': _totalSpace.value - _availableSpace.value,
          'usagePercentage': _totalSpace.value > 0
              ? ((_totalSpace.value - _availableSpace.value) /
                        _totalSpace.value *
                        100)
                    .round()
              : 0,
        };
      }

      _storageStats.assignAll(stats);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update storage stats: $e');
      }
    }
  }

  // ==================== APP SETTINGS ====================

  /// Save app setting with automatic type detection
  Future<void> saveAppSetting<T>(String key, T value) async {
    await LocalStorage.saveAppSetting(key, value);
    await updateStorageStats();
  }

  /// Get app setting with type safety
  T? getAppSetting<T>(String key, [T? defaultValue]) {
    return LocalStorage.getAppSetting<T>(key, defaultValue);
  }

  /// Remove app setting
  Future<void> removeAppSetting(String key) async {
    await LocalStorage.removeAppSetting(key);
    await updateStorageStats();
  }

  // ==================== USER PREFERENCES ====================

  /// Save user preference
  Future<void> saveUserPreference<T>(String key, T value) async {
    await LocalStorage.saveUserPreference(key, value);
    await updateStorageStats();
  }

  /// Get user preference
  T? getUserPreference<T>(String key, [T? defaultValue]) {
    return LocalStorage.getUserPreference<T>(key, defaultValue);
  }

  /// Remove user preference
  Future<void> removeUserPreference(String key) async {
    await LocalStorage.removeUserPreference(key);
    await updateStorageStats();
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Save cache data with expiration
  Future<void> saveCacheData<T>(
    String key,
    T value, [
    Duration? expiration,
  ]) async {
    await LocalStorage.saveCacheData(key, value, expiration);
    await updateStorageStats();
  }

  /// Get cache data
  T? getCacheData<T>(String key) {
    return LocalStorage.getCacheData<T>(key);
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    await LocalStorage.clearExpiredCache();
    await updateStorageStats();
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await LocalStorage.clearContainer(StorageContainer.cacheData);
    await updateStorageStats();
  }

  // ==================== SECURE DATA ====================

  /// Save secure data
  Future<void> saveSecureData<T>(String key, T value) async {
    await LocalStorage.saveSecureData(key, value);
  }

  /// Get secure data
  T? getSecureData<T>(String key, [T? defaultValue]) {
    return LocalStorage.getSecureData<T>(key, defaultValue);
  }

  /// Remove secure data
  Future<void> removeSecureData(String key) async {
    await LocalStorage.removeSecureData(key);
  }

  // ==================== ANDROID PLATFORM INTEGRATION ====================

  /// Get video files from Android MediaStore
  Future<List<Map<String, dynamic>>> getVideoFilesFromMediaStore() async {
    if (!Platform.isAndroid) return [];
    return await AndroidPlatform.getVideoFilesFromMediaStore();
  }

  /// Scan media files in directories
  Future<List<Map<String, dynamic>>> scanMediaFiles([
    List<String>? directories,
  ]) async {
    if (!Platform.isAndroid) return [];

    final scanDirs = directories ?? _externalDirectories;
    return await AndroidPlatform.scanMediaFiles(scanDirs);
  }

  /// Add file to MediaStore
  Future<bool> addToMediaStore(String filePath) async {
    if (!Platform.isAndroid) return false;
    return await AndroidPlatform.addToMediaStore(filePath);
  }

  /// Delete file from MediaStore
  Future<bool> deleteFromMediaStore(String filePath) async {
    if (!Platform.isAndroid) return false;
    return await AndroidPlatform.deleteFromMediaStore(filePath);
  }

  /// Check storage permissions
  Future<bool> hasStoragePermissions() async {
    if (!Platform.isAndroid) return true;
    return await AndroidPlatform.hasStoragePermissions();
  }

  /// Request storage permissions
  Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) return true;
    return await AndroidPlatform.requestStoragePermissions();
  }

  /// Request manage external storage permission (Android 11+)
  Future<bool> requestManageExternalStoragePermission() async {
    if (!Platform.isAndroid) return true;
    return await AndroidPlatform.requestManageExternalStoragePermission();
  }

  // ==================== UTILITY METHODS ====================

  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get storage usage percentage
  double getStorageUsagePercentage() {
    if (_totalSpace.value <= 0) return 0.0;
    final used = _totalSpace.value - _availableSpace.value;
    return (used / _totalSpace.value) * 100;
  }

  /// Check if storage is low (less than 10% available)
  bool isStorageLow() {
    return getStorageUsagePercentage() > 90;
  }

  /// Get available space formatted
  String getAvailableSpaceFormatted() {
    return formatBytes(_availableSpace.value);
  }

  /// Get total space formatted
  String getTotalSpaceFormatted() {
    return formatBytes(_totalSpace.value);
  }

  /// Get used space formatted
  String getUsedSpaceFormatted() {
    final used = _totalSpace.value - _availableSpace.value;
    return formatBytes(used);
  }

  /// Refresh storage information
  Future<void> refreshStorageInfo() async {
    if (Platform.isAndroid) {
      await _loadAndroidStorageInfo();
    }
    await updateStorageStats();
  }

  /// Clear all data (factory reset)
  Future<void> clearAllData() async {
    await LocalStorage.clearAll();
    await updateStorageStats();

    appLog(
      'All app data has been cleared',
    );
  }

  /// Export storage statistics
  Map<String, dynamic> exportStorageStats() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'stats': _storageStats,
      'platform': Platform.operatingSystem,
      'isAndroid': Platform.isAndroid,
    };
  }

  /// Listen to storage changes
  void listenToStorageChanges(VoidCallback callback) {
    _storageStats.listen((_) => callback());
  }

  @override
  void onClose() {
    _storageStats.close();
    _isInitialized.close();
    _externalDirectories.close();
    _availableSpace.close();
    _totalSpace.close();
    super.onClose();
  }
}
