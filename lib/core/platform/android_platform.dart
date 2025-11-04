import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-specific platform implementations
class AndroidPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.kitmedia.player/android',
  );

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Initialize Android-specific features
  static Future<void> initialize() async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('initialize');
      if (kDebugMode) {
        print('Android platform initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Android platform: $e');
      }
    }
  }

  // ==================== STORAGE MANAGEMENT ====================

  /// Get external storage directories
  static Future<List<String>> getExternalStorageDirectories() async {
    if (!isAndroid) return [];

    try {
      final result = await _channel.invokeMethod(
        'getExternalStorageDirectories',
      );
      return List<String>.from(result ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get external storage directories: $e');
      }
      return [];
    }
  }

  /// Get available storage space in bytes
  static Future<int> getAvailableStorageSpace([String? path]) async {
    if (!isAndroid) return 0;

    try {
      final result = await _channel.invokeMethod('getAvailableStorageSpace', {
        'path': path,
      });
      return result ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get available storage space: $e');
      }
      return 0;
    }
  }

  /// Get total storage space in bytes
  static Future<int> getTotalStorageSpace([String? path]) async {
    if (!isAndroid) return 0;

    try {
      final result = await _channel.invokeMethod('getTotalStorageSpace', {
        'path': path,
      });
      return result ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get total storage space: $e');
      }
      return 0;
    }
  }

  /// Check if external storage is available
  static Future<bool> isExternalStorageAvailable() async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('isExternalStorageAvailable');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check external storage availability: $e');
      }
      return false;
    }
  }

  // ==================== MEDIA SCANNING ====================

  /// Scan media files in specified directories
  static Future<List<Map<String, dynamic>>> scanMediaFiles(
    List<String> directories,
  ) async {
    if (!isAndroid) return [];

    try {
      final result = await _channel.invokeMethod('scanMediaFiles', {
        'directories': directories,
      });
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to scan media files: $e');
      }
      return [];
    }
  }

  /// Get video files from MediaStore
  static Future<List<Map<String, dynamic>>>
  getVideoFilesFromMediaStore() async {
    if (!isAndroid) return [];

    try {
      final result = await _channel.invokeMethod('getVideoFilesFromMediaStore');
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get video files from MediaStore: $e');
      }
      return [];
    }
  }

  /// Add file to MediaStore
  static Future<bool> addToMediaStore(String filePath) async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('addToMediaStore', {
        'filePath': filePath,
      });
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add file to MediaStore: $e');
      }
      return false;
    }
  }

  /// Delete file from MediaStore
  static Future<bool> deleteFromMediaStore(String filePath) async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('deleteFromMediaStore', {
        'filePath': filePath,
      });
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete file from MediaStore: $e');
      }
      return false;
    }
  }

  // ==================== PERMISSIONS ====================

  /// Request storage permissions
  static Future<bool> requestStoragePermissions() async {
    if (!isAndroid) return true;

    try {
      final result = await _channel.invokeMethod('requestStoragePermissions');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request storage permissions: $e');
      }
      return false;
    }
  }

  /// Check if storage permissions are granted
  static Future<bool> hasStoragePermissions() async {
    if (!isAndroid) return true;

    try {
      final result = await _channel.invokeMethod('hasStoragePermissions');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check storage permissions: $e');
      }
      return false;
    }
  }

  /// Request manage external storage permission (Android 11+)
  static Future<bool> requestManageExternalStoragePermission() async {
    if (!isAndroid) return true;

    try {
      final result = await _channel.invokeMethod(
        'requestManageExternalStoragePermission',
      );
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request manage external storage permission: $e');
      }
      return false;
    }
  }

  // ==================== SYSTEM INTEGRATION ====================

  /// Get Android version
  static Future<int> getAndroidVersion() async {
    if (!isAndroid) return 0;

    try {
      final result = await _channel.invokeMethod('getAndroidVersion');
      return result ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get Android version: $e');
      }
      return 0;
    }
  }

  /// Check if device is rooted
  static Future<bool> isDeviceRooted() async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('isDeviceRooted');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check if device is rooted: $e');
      }
      return false;
    }
  }

  /// Get device manufacturer
  static Future<String> getDeviceManufacturer() async {
    if (!isAndroid) return 'Unknown';

    try {
      final result = await _channel.invokeMethod('getDeviceManufacturer');
      return result ?? 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get device manufacturer: $e');
      }
      return 'Unknown';
    }
  }

  /// Get device model
  static Future<String> getDeviceModel() async {
    if (!isAndroid) return 'Unknown';

    try {
      final result = await _channel.invokeMethod('getDeviceModel');
      return result ?? 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get device model: $e');
      }
      return 'Unknown';
    }
  }

  // ==================== PERFORMANCE ====================

  /// Set high performance mode
  static Future<bool> setHighPerformanceMode(bool enabled) async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('setHighPerformanceMode', {
        'enabled': enabled,
      });
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set high performance mode: $e');
      }
      return false;
    }
  }

  /// Get CPU usage
  static Future<double> getCpuUsage() async {
    if (!isAndroid) return 0.0;

    try {
      final result = await _channel.invokeMethod('getCpuUsage');
      return (result ?? 0.0).toDouble();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get CPU usage: $e');
      }
      return 0.0;
    }
  }

  /// Get memory usage
  static Future<Map<String, int>> getMemoryUsage() async {
    if (!isAndroid) return {};

    try {
      final result = await _channel.invokeMethod('getMemoryUsage');
      return Map<String, int>.from(result ?? {});
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get memory usage: $e');
      }
      return {};
    }
  }

  // ==================== UTILITIES ====================

  /// Show native toast message
  static Future<void> showToast(String message, {int duration = 2000}) async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('showToast', {
        'message': message,
        'duration': duration,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show toast: $e');
      }
    }
  }

  /// Vibrate device
  static Future<void> vibrate({int duration = 100}) async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
    } catch (e) {
      if (kDebugMode) {
        print('Failed to vibrate: $e');
      }
    }
  }

  /// Keep screen on
  static Future<void> keepScreenOn(bool keepOn) async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('keepScreenOn', {'keepOn': keepOn});
    } catch (e) {
      if (kDebugMode) {
        print('Failed to keep screen on: $e');
      }
    }
  }

  /// Set system UI visibility
  static Future<void> setSystemUIVisibility(bool fullscreen) async {
    if (!isAndroid) return;

    try {
      await _channel.invokeMethod('setSystemUIVisibility', {
        'fullscreen': fullscreen,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set system UI visibility: $e');
      }
    }
  }
}
