import 'package:flutter/services.dart';
import '../utils/logger.dart';

class NativeVideoDeleteService {
  static const MethodChannel _channel = MethodChannel(
    'com.kitmedia/video_operations',
  );

  /// Delete a video file using native Android MediaStore API
  Future<bool> deleteVideo(String filePath) async {
    try {
      appLog('🔧 Using native deletion for: $filePath');

      // Check if we need to show permission dialog
      final needsPermission = await needsDeletePermission();
      if (needsPermission) {
        appLog('📱 Android 11+ detected - will show system delete dialog');
      }

      final result = await _channel.invokeMethod('deleteVideo', {
        'filePath': filePath,
      });

      appLog('📱 Native deletion result: $result');
      return result == true;
    } on PlatformException catch (e) {
      appLog('❌ Native deletion failed: ${e.message}');
      return false;
    } catch (e) {
      appLog('❌ Unexpected error in native deletion: $e');
      return false;
    }
  }

  /// Check if the device needs delete permission (Android 11+)
  Future<bool> needsDeletePermission() async {
    try {
      final result = await _channel.invokeMethod('needsDeletePermission');
      return result == true;
    } on PlatformException catch (e) {
      if (e.code == 'MissingPluginException') {
        appLog('⚠️ Plugin method not available, assuming Android 11+');
        return true; // Assume we need permission for safety
      }
      appLog('❌ Error checking delete permission requirement: ${e.message}');
      return false;
    } catch (e) {
      appLog('❌ Error checking delete permission requirement: $e');
      return false;
    }
  }

  /// Check if a video file exists using native methods
  Future<bool> fileExists(String filePath) async {
    try {
      final result = await _channel.invokeMethod('fileExists', {
        'filePath': filePath,
      });

      return result == true;
    } on PlatformException catch (e) {
      appLog('❌ Native file check failed: ${e.message}');
      return false;
    } catch (e) {
      appLog('❌ Unexpected error in native file check: $e');
      return false;
    }
  }

  /// Get video file info using native methods
  Future<Map<String, dynamic>?> getVideoInfo(String filePath) async {
    try {
      final result = await _channel.invokeMethod('getVideoInfo', {
        'filePath': filePath,
      });

      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      appLog('❌ Native video info failed: ${e.message}');
      return null;
    } catch (e) {
      appLog('❌ Unexpected error in native video info: $e');
      return null;
    }
  }
}
