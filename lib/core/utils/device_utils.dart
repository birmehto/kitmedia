import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final Battery _battery = Battery();

  /// Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'androidId': androidInfo.id,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          // 'totalMemory': androidInfo.totalMemory, // Not available in current version
          'systemFeatures': androidInfo.systemFeatures,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'localizedModel': iosInfo.localizedModel,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        });
      }
    } catch (e) {
      deviceData['error'] = e.toString();
    }

    return deviceData;
  }

  /// Get app information
  static Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'buildSignature': packageInfo.buildSignature,
        'installerStore': packageInfo.installerStore,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get battery information
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      final isInBatterySaveMode = await _battery.isInBatterySaveMode;

      return {
        'level': batteryLevel,
        'state': batteryState.toString(),
        'isInBatterySaveMode': isInBatterySaveMode,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get battery level stream
  static Stream<BatteryState> get batteryStateStream =>
      _battery.onBatteryStateChanged;

  /// Check if device is in battery save mode
  static Future<bool> isInBatterySaveMode() async {
    try {
      return await _battery.isInBatterySaveMode;
    } catch (e) {
      return false;
    }
  }

  /// Get available display modes (Android only)
  static Future<List<DisplayMode>> getDisplayModes() async {
    try {
      if (Platform.isAndroid) {
        return await FlutterDisplayMode.supported;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Set display mode (Android only)
  static Future<bool> setDisplayMode(DisplayMode mode) async {
    try {
      if (Platform.isAndroid) {
        await FlutterDisplayMode.setPreferredMode(mode);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get current display mode (Android only)
  static Future<DisplayMode?> getCurrentDisplayMode() async {
    try {
      if (Platform.isAndroid) {
        return await FlutterDisplayMode.active;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Set high refresh rate mode (Android only)
  static Future<bool> setHighRefreshRate() async {
    try {
      if (Platform.isAndroid) {
        final modes = await FlutterDisplayMode.supported;
        if (modes.isNotEmpty) {
          // Find the mode with highest refresh rate
          final highestRefreshMode = modes.reduce(
            (a, b) => a.refreshRate > b.refreshRate ? a : b,
          );
          await FlutterDisplayMode.setPreferredMode(highestRefreshMode);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if device supports high refresh rate
  static Future<bool> supportsHighRefreshRate() async {
    try {
      if (Platform.isAndroid) {
        final modes = await FlutterDisplayMode.supported;
        return modes.any((mode) => mode.refreshRate > 60);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get device orientation
  static Future<String> getDeviceOrientation() async {
    try {
      // This would need to be implemented with proper orientation detection
      return 'portrait'; // Placeholder
    } catch (e) {
      return 'unknown';
    }
  }

  /// Check if device is tablet
  static Future<bool> isTablet() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Simple heuristic: check if it's a tablet based on screen size
        // This is a simplified approach
        return androidInfo.model.toLowerCase().contains('tab') ||
            androidInfo.model.toLowerCase().contains('pad');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model.toLowerCase().contains('ipad');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is emulator
  static Future<bool> isEmulator() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get system locale
  static String getSystemLocale() {
    try {
      return Platform.localeName;
    } catch (e) {
      return 'en_US';
    }
  }

  /// Vibrate device
  static Future<void> vibrate({
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Light haptic feedback
  static Future<void> lightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Medium haptic feedback
  static Future<void> mediumHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Heavy haptic feedback
  static Future<void> heavyHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Selection haptic feedback
  static Future<void> selectionHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get comprehensive device summary
  static Future<Map<String, dynamic>> getDeviceSummary() async {
    final deviceInfo = await getDeviceInfo();
    final appInfo = await getAppInfo();
    final batteryInfo = await getBatteryInfo();
    final isTabletDevice = await isTablet();
    final isEmulatorDevice = await isEmulator();
    final supportsHighRefresh = await supportsHighRefreshRate();

    return {
      'device': deviceInfo,
      'app': appInfo,
      'battery': batteryInfo,
      'isTablet': isTabletDevice,
      'isEmulator': isEmulatorDevice,
      'supportsHighRefreshRate': supportsHighRefresh,
      'systemLocale': getSystemLocale(),
    };
  }
}
