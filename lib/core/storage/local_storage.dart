import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Centralized local storage management using GetStorage
/// Provides type-safe storage operations with different storage containers
class LocalStorage {
  // Storage containers for different data types
  static late GetStorage _appSettings;
  static late GetStorage _userPreferences;
  static late GetStorage _cacheData;
  static late GetStorage _secureData;

  static bool _isInitialized = false;

  /// Initialize all storage containers
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await GetStorage.init('app_settings');
      await GetStorage.init('user_preferences');
      await GetStorage.init('cache_data');
      await GetStorage.init('secure_data');

      _appSettings = GetStorage('app_settings');
      _userPreferences = GetStorage('user_preferences');
      _cacheData = GetStorage('cache_data');
      _secureData = GetStorage('secure_data');

      _isInitialized = true;

      if (kDebugMode) {
        print('LocalStorage initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize LocalStorage: $e');
      }
      rethrow;
    }
  }

  /// Ensure storage is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'LocalStorage not initialized. Call LocalStorage.initialize() first.',
      );
    }
  }

  // ==================== APP SETTINGS ====================

  /// Save app setting
  static Future<void> saveAppSetting<T>(String key, T value) async {
    _ensureInitialized();
    await _appSettings.write(key, value);
  }

  /// Get app setting
  static T? getAppSetting<T>(String key, [T? defaultValue]) {
    _ensureInitialized();
    return _appSettings.read<T>(key) ?? defaultValue;
  }

  /// Remove app setting
  static Future<void> removeAppSetting(String key) async {
    _ensureInitialized();
    await _appSettings.remove(key);
  }

  /// Check if app setting exists
  static bool hasAppSetting(String key) {
    _ensureInitialized();
    return _appSettings.hasData(key);
  }

  // ==================== USER PREFERENCES ====================

  /// Save user preference
  static Future<void> saveUserPreference<T>(String key, T value) async {
    _ensureInitialized();
    await _userPreferences.write(key, value);
  }

  /// Get user preference
  static T? getUserPreference<T>(String key, [T? defaultValue]) {
    _ensureInitialized();
    return _userPreferences.read<T>(key) ?? defaultValue;
  }

  /// Remove user preference
  static Future<void> removeUserPreference(String key) async {
    _ensureInitialized();
    await _userPreferences.remove(key);
  }

  /// Check if user preference exists
  static bool hasUserPreference(String key) {
    _ensureInitialized();
    return _userPreferences.hasData(key);
  }

  // ==================== CACHE DATA ====================

  /// Save cache data with optional expiration
  static Future<void> saveCacheData<T>(
    String key,
    T value, [
    Duration? expiration,
  ]) async {
    _ensureInitialized();
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await _cacheData.write(key, data);
  }

  /// Get cache data (returns null if expired)
  static T? getCacheData<T>(String key) {
    _ensureInitialized();
    final data = _cacheData.read<Map<String, dynamic>>(key);
    if (data == null) return null;

    final timestamp = data['timestamp'] as int?;
    final expiration = data['expiration'] as int?;

    if (expiration != null && timestamp != null) {
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp + expiration,
      );
      if (DateTime.now().isAfter(expirationTime)) {
        // Data expired, remove it
        _cacheData.remove(key);
        return null;
      }
    }

    return data['value'] as T?;
  }

  /// Remove cache data
  static Future<void> removeCacheData(String key) async {
    _ensureInitialized();
    await _cacheData.remove(key);
  }

  /// Clear expired cache data
  static Future<void> clearExpiredCache() async {
    _ensureInitialized();
    final keys = _cacheData.getKeys();
    final now = DateTime.now();

    for (final key in keys) {
      final data = _cacheData.read<Map<String, dynamic>>(key);
      if (data != null) {
        final timestamp = data['timestamp'] as int?;
        final expiration = data['expiration'] as int?;

        if (expiration != null && timestamp != null) {
          final expirationTime = DateTime.fromMillisecondsSinceEpoch(
            timestamp + expiration,
          );
          if (now.isAfter(expirationTime)) {
            await _cacheData.remove(key);
          }
        }
      }
    }
  }

  // ==================== SECURE DATA ====================

  /// Save secure data (for sensitive information)
  static Future<void> saveSecureData<T>(String key, T value) async {
    _ensureInitialized();
    await _secureData.write(key, value);
  }

  /// Get secure data
  static T? getSecureData<T>(String key, [T? defaultValue]) {
    _ensureInitialized();
    return _secureData.read<T>(key) ?? defaultValue;
  }

  /// Remove secure data
  static Future<void> removeSecureData(String key) async {
    _ensureInitialized();
    await _secureData.remove(key);
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data from a specific container
  static Future<void> clearContainer(StorageContainer container) async {
    _ensureInitialized();
    switch (container) {
      case StorageContainer.appSettings:
        await _appSettings.erase();
        break;
      case StorageContainer.userPreferences:
        await _userPreferences.erase();
        break;
      case StorageContainer.cacheData:
        await _cacheData.erase();
        break;
      case StorageContainer.secureData:
        await _secureData.erase();
        break;
    }
  }

  /// Clear all storage containers
  static Future<void> clearAll() async {
    _ensureInitialized();
    await Future.wait([
      _appSettings.erase(),
      _userPreferences.erase(),
      _cacheData.erase(),
      _secureData.erase(),
    ]);
  }

  /// Get storage size for a container
  static int getContainerSize(StorageContainer container) {
    _ensureInitialized();
    switch (container) {
      case StorageContainer.appSettings:
        return _appSettings.getKeys().length;
      case StorageContainer.userPreferences:
        return _userPreferences.getKeys().length;
      case StorageContainer.cacheData:
        return _cacheData.getKeys().length;
      case StorageContainer.secureData:
        return _secureData.getKeys().length;
    }
  }

  /// Get all keys from a container
  static Iterable<String> getKeys(StorageContainer container) {
    _ensureInitialized();
    switch (container) {
      case StorageContainer.appSettings:
        return _appSettings.getKeys();
      case StorageContainer.userPreferences:
        return _userPreferences.getKeys();
      case StorageContainer.cacheData:
        return _cacheData.getKeys();
      case StorageContainer.secureData:
        return _secureData.getKeys();
    }
  }

  /// Listen to changes in a specific container
  static void listenToContainer(
    StorageContainer container,
    VoidCallback callback,
  ) {
    _ensureInitialized();
    switch (container) {
      case StorageContainer.appSettings:
        _appSettings.listen(callback);
        break;
      case StorageContainer.userPreferences:
        _userPreferences.listen(callback);
        break;
      case StorageContainer.cacheData:
        _cacheData.listen(callback);
        break;
      case StorageContainer.secureData:
        _secureData.listen(callback);
        break;
    }
  }

  /// Get storage statistics
  static Map<String, dynamic> getStorageStats() {
    _ensureInitialized();
    return {
      'appSettings': {
        'keys': _appSettings.getKeys().length,
        'container': 'app_settings',
      },
      'userPreferences': {
        'keys': _userPreferences.getKeys().length,
        'container': 'user_preferences',
      },
      'cacheData': {
        'keys': _cacheData.getKeys().length,
        'container': 'cache_data',
      },
      'secureData': {
        'keys': _secureData.getKeys().length,
        'container': 'secure_data',
      },
      'totalContainers': 4,
      'isInitialized': _isInitialized,
    };
  }
}

/// Storage container types
enum StorageContainer { appSettings, userPreferences, cacheData, secureData }

/// Storage keys constants for type safety
class StorageKeys {
  // App Settings
  static const String appVersion = 'app_version';
  static const String firstLaunch = 'first_launch';
  static const String lastUpdateCheck = 'last_update_check';

  // User Preferences
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String dynamicColors = 'dynamic_colors';
}
