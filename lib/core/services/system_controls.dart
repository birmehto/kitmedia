import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import '../utils/logger.dart';

/// System controls implementation using screen_brightness and volume_controller packages
class SystemControls {
  SystemControls._();
  static SystemControls? _instance;
  static SystemControls get instance => _instance ??= SystemControls._();

  // Current values
  double _currentBrightness = 0.5;
  double _currentVolume = 0.5;

  // Getters
  double get currentBrightness => _currentBrightness;
  double get currentVolume => _currentVolume;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Get current system brightness
      _currentBrightness = await ScreenBrightness().application;
      appLog(
        'Current system brightness: ${(_currentBrightness * 100).round()}%',
      );
    } catch (e) {
      appLog('Could not get system brightness: $e', color: 'yellow');
      _currentBrightness = 0.5;
    }

    try {
      // Get current system volume
      _currentVolume = await VolumeController.instance.getVolume();
      appLog('Current system volume: ${(_currentVolume * 100).round()}%');
    } catch (e) {
      appLog('Could not get system volume: $e', color: 'yellow');
      _currentVolume = 0.5;
    }

    appLog('SystemControls initialized successfully');
  }

  /// Set system brightness (0.0 to 1.0)
  Future<void> setBrightness(double brightness) async {
    try {
      final clampedBrightness = brightness.clamp(0.0, 1.0);
      await ScreenBrightness().setApplicationScreenBrightness(
        clampedBrightness,
      );
      _currentBrightness = clampedBrightness;
      appLog('Brightness set to: ${(clampedBrightness * 100).round()}%');
    } catch (e) {
      appLog('Could not set system brightness: $e', color: 'yellow');
      // Still update our internal value for UI consistency
      _currentBrightness = brightness.clamp(0.0, 1.0);
    }
  }

  /// Set system volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await VolumeController.instance.setVolume(clampedVolume);
      _currentVolume = clampedVolume;
      appLog('Volume set to: ${(clampedVolume * 100).round()}%');
    } catch (e) {
      appLog('Could not set system volume: $e', color: 'yellow');
      // Still update our internal value for UI consistency
      _currentVolume = volume.clamp(0.0, 1.0);
    }
  }

  /// Adjust brightness by delta (-1.0 to 1.0)
  Future<void> adjustBrightness(double delta) async {
    final newBrightness = (_currentBrightness + delta).clamp(0.0, 1.0);
    await setBrightness(newBrightness);
  }

  /// Adjust volume by delta (-1.0 to 1.0)
  Future<void> adjustVolume(double delta) async {
    final newVolume = (_currentVolume + delta).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  /// Mute system volume by setting it to 0
  Future<void> muteVolume() async {
    try {
      await VolumeController.instance.setVolume(0.0);
      _currentVolume = 0.0;
      appLog('Volume muted');
    } catch (e) {
      appLog('Could not mute volume: $e', color: 'yellow');
    }
  }

  /// Remove volume listener functionality (not available in current version)
  void removeVolumeListener() {
    try {
      VolumeController.instance.removeListener();
      appLog('Volume listener removed');
    } catch (e) {
      appLog('Could not remove volume listener: $e', color: 'yellow');
    }
  }

  /// Check if brightness control is available
  Future<bool> get hasBrightnessControl async {
    try {
      await ScreenBrightness().application;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if volume control is available
  Future<bool> get hasVolumeControl async {
    try {
      await VolumeController.instance.getVolume();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Provide haptic feedback for better UX
  void provideFeedback() {
    HapticFeedback.selectionClick();
  }

  /// Reset brightness to system default and dispose resources
  Future<void> dispose() async {
    try {
      // Reset brightness to system default when disposing
      await ScreenBrightness().resetApplicationScreenBrightness();
      appLog('Screen brightness reset to system default');
    } catch (e) {
      appLog('Could not reset screen brightness: $e', color: 'yellow');
    }
  }
}
