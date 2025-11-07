import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../platform/android_platform.dart';
import '../storage/local_storage.dart';
import '../utils/network_utils.dart';
import 'storage_service.dart';

/// Service responsible for initializing all core app services
class AppInitializationService extends GetxService {
  static AppInitializationService get to => Get.find();

  final RxBool _isInitialized = false.obs;
  final RxString _initializationStatus = 'Not Started'.obs;
  final RxDouble _initializationProgress = 0.0.obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  String get initializationStatus => _initializationStatus.value;
  double get initializationProgress => _initializationProgress.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeApp();
  }

  /// Initialize all app services in the correct order
  Future<void> initializeApp() async {
    try {
      _updateStatus('Starting initialization...', 0.0);

      // Step 1: Initialize Local Storage
      _updateStatus('Initializing local storage...', 0.1);
      await LocalStorage.initialize();

      // Step 2: Initialize Storage Service
      _updateStatus('Setting up storage service...', 0.3);
      Get.put(StorageService(), permanent: true);
      await StorageService.to.initialize();

      // Step 3: Initialize Platform Services
      _updateStatus('Initializing platform services...', 0.5);
      await AndroidPlatform.initialize();

      // Step 4: Initialize Network Utils
      _updateStatus('Setting up network utilities...', 0.7);
      await NetworkUtils.initialize();

      // Step 5: Load App Configuration
      _updateStatus('Loading app configuration...', 0.8);
      await _loadAppConfiguration();

      // Step 6: Perform First Launch Setup
      _updateStatus('Performing first launch setup...', 0.9);
      await _performFirstLaunchSetup();

      // Step 7: Complete Initialization
      _updateStatus('Initialization complete', 1.0);
      _isInitialized.value = true;

      if (kDebugMode) {
        print('App initialization completed successfully');
      }
    } catch (e) {
      _updateStatus('Initialization failed: $e', 0.0);
      if (kDebugMode) {
        print('App initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Update initialization status and progress
  void _updateStatus(String status, double progress) {
    _initializationStatus.value = status;
    _initializationProgress.value = progress;

    if (kDebugMode) {
      print('Initialization: $status (${(progress * 100).toInt()}%)');
    }
  }

  /// Load app configuration from storage
  Future<void> _loadAppConfiguration() async {
    try {
      final storage = StorageService.to;

      // Load app version and check for updates
      final currentVersion = storage.getAppSetting<String>(
        StorageKeys.appVersion,
      );
      const newVersion = '1.0.0'; // This should come from app config

      if (currentVersion != newVersion) {
        await _handleAppUpdate(currentVersion, newVersion);
        await storage.saveAppSetting(StorageKeys.appVersion, newVersion);
      }

      // Load other app settings
      final lastUpdateCheck = storage.getAppSetting<int>(
        StorageKeys.lastUpdateCheck,
      );
      if (lastUpdateCheck == null ||
          DateTime.now().millisecondsSinceEpoch - lastUpdateCheck > 86400000) {
        // 24 hours
        await storage.saveAppSetting(
          StorageKeys.lastUpdateCheck,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load app configuration: $e');
      }
    }
  }

  /// Handle app update logic
  Future<void> _handleAppUpdate(String? oldVersion, String newVersion) async {
    try {
      if (kDebugMode) {
        print('App updated from $oldVersion to $newVersion');
      }

      // Perform migration tasks if needed
      if (oldVersion == null) {
        // First installation
        await _performFirstInstallation();
      } else {
        // App update
        await _performAppUpdate(oldVersion, newVersion);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to handle app update: $e');
      }
    }
  }

  /// Perform first installation setup
  Future<void> _performFirstInstallation() async {
    try {
      final storage = StorageService.to;

      // Set default preferences
      await storage.saveUserPreference(StorageKeys.themeMode, 'system');
      await storage.saveUserPreference(StorageKeys.languageCode, 'en');
      await storage.saveUserPreference(StorageKeys.dynamicColors, true);

      // Mark first launch as complete
      await storage.saveAppSetting(StorageKeys.firstLaunch, false);

      if (kDebugMode) {
        print('First installation setup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to perform first installation: $e');
      }
    }
  }

  /// Perform app update migration
  Future<void> _performAppUpdate(String oldVersion, String newVersion) async {
    try {
      // Add migration logic here based on version differences
      if (kDebugMode) {
        print(
          'Performing app update migration from $oldVersion to $newVersion',
        );
      }

      // Example migration logic
      // if (oldVersion == '0.9.0' && newVersion == '1.0.0') {
      //   await _migrateToV1();
      // }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to perform app update: $e');
      }
    }
  }

  /// Perform first launch setup
  Future<void> _performFirstLaunchSetup() async {
    try {
      final storage = StorageService.to;
      final isFirstLaunch =
          storage.getAppSetting<bool>(StorageKeys.firstLaunch) ?? true;

      if (isFirstLaunch) {
        // Request necessary permissions
        await _requestInitialPermissions();

        // Clear any existing cache
        await storage.clearExpiredCache();

        // Mark first launch as complete
        await storage.saveAppSetting(StorageKeys.firstLaunch, false);

        if (kDebugMode) {
          print('First launch setup completed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to perform first launch setup: $e');
      }
    }
  }

  /// Request initial permissions
  Future<void> _requestInitialPermissions() async {
    try {
      final storage = StorageService.to;

      // Request storage permissions
      final hasStoragePermissions = await storage.hasStoragePermissions();
      if (!hasStoragePermissions) {
        await storage.requestStoragePermissions();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request initial permissions: $e');
      }
    }
  }

  /// Get initialization summary
  Map<String, dynamic> getInitializationSummary() {
    return {
      'isInitialized': _isInitialized.value,
      'status': _initializationStatus.value,
      'progress': _initializationProgress.value,
      'timestamp': DateTime.now().toIso8601String(),
      'services': {'storageService': StorageService.to.isInitialized},
    };
  }

  /// Reinitialize app (for debugging or recovery)
  Future<void> reinitialize() async {
    _isInitialized.value = false;
    await initializeApp();
  }

  @override
  void onClose() {
    _isInitialized.close();
    _initializationStatus.close();
    _initializationProgress.close();
    super.onClose();
  }
}
