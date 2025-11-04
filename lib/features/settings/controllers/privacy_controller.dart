import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/storage/local_storage.dart';

class PrivacyController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();

  final RxBool _analyticsEnabled = false.obs;
  final RxBool _crashReportingEnabled = true.obs;
  final RxBool _usageStatsEnabled = false.obs;
  final RxBool _locationAccessEnabled = false.obs;
  final RxBool _biometricLockEnabled = false.obs;
  final RxBool _incognitoModeEnabled = false.obs;

  // Getters
  bool get analyticsEnabled => _analyticsEnabled.value;
  bool get crashReportingEnabled => _crashReportingEnabled.value;
  bool get usageStatsEnabled => _usageStatsEnabled.value;
  bool get locationAccessEnabled => _locationAccessEnabled.value;
  bool get biometricLockEnabled => _biometricLockEnabled.value;
  bool get incognitoModeEnabled => _incognitoModeEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.to;

    _analyticsEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.analyticsEnabled) ?? false;
    _crashReportingEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.crashReporting) ?? true;
    _usageStatsEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.usageStats) ?? false;
    _locationAccessEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.locationAccess) ?? false;
    _biometricLockEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.biometricLock) ?? false;
    _incognitoModeEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.incognitoMode) ?? false;

    update();
  }

  Future<void> setAnalytics(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.analyticsEnabled,
      enabled,
    );
    _analyticsEnabled.value = enabled;
    update();
  }

  Future<void> setCrashReporting(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.crashReporting,
      enabled,
    );
    _crashReportingEnabled.value = enabled;
    update();
  }

  Future<void> setUsageStats(bool enabled) async {
    await StorageService.to.saveUserPreference(StorageKeys.usageStats, enabled);
    _usageStatsEnabled.value = enabled;
    update();
  }

  Future<void> setLocationAccess(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.locationAccess,
      enabled,
    );
    _locationAccessEnabled.value = enabled;
    update();
  }

  Future<void> setBiometricLock(bool enabled) async {
    if (enabled) {
      // Check if biometric authentication is available
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        Get.snackbar(
          'Biometric Authentication',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Test biometric authentication
      try {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to enable biometric lock',
        );

        if (!didAuthenticate) {
          Get.snackbar(
            'Authentication Failed',
            'Biometric authentication was not successful',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      } catch (e) {
        Get.snackbar(
          'Authentication Error',
          'Failed to authenticate: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    await StorageService.to.saveUserPreference(
      StorageKeys.biometricLock,
      enabled,
    );
    _biometricLockEnabled.value = enabled;
    update();

    if (enabled) {
      Get.snackbar(
        'Biometric Lock Enabled',
        'App will require biometric authentication to open',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> authenticateUser() async {
    if (!_biometricLockEnabled.value) return true;

    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return true;

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access KitMedia',
      );

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<void> setIncognitoMode(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.incognitoMode,
      enabled,
    );
    _incognitoModeEnabled.value = enabled;
    update();
  }

  Future<void> resetAllData() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will delete all app data including settings, cache, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await StorageService.to.clearAllData();

        // Reset all controllers to default values
        _analyticsEnabled.value = false;
        _crashReportingEnabled.value = true;
        _usageStatsEnabled.value = false;
        _locationAccessEnabled.value = false;
        _biometricLockEnabled.value = false;
        _incognitoModeEnabled.value = false;

        update();

        Get.snackbar(
          'Data Reset',
          'All app data has been reset to defaults',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to reset data: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
