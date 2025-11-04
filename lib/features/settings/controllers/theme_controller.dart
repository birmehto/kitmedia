import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/storage/local_storage.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final RxBool _isDynamicColorEnabled = true.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDynamicColorEnabled => _isDynamicColorEnabled.value;

  String get themeModeString {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.to;
    final themeModeString =
        storage.getUserPreference<String>(StorageKeys.themeMode) ?? 'system';
    final dynamicColorEnabled =
        storage.getUserPreference<bool>(StorageKeys.dynamicColors) ?? true;

    // Convert string to ThemeMode
    switch (themeModeString) {
      case 'light':
        _themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        break;
      default:
        _themeMode.value = ThemeMode.system;
        break;
    }

    _isDynamicColorEnabled.value = dynamicColorEnabled;
    update(); // Notify GetBuilder widgets
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    // Convert ThemeMode to string
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await StorageService.to.saveUserPreference(
      StorageKeys.themeMode,
      themeModeString,
    );
    _themeMode.value = themeMode;
    Get.changeThemeMode(themeMode);
    update(); // Notify GetBuilder widgets
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.dynamicColors,
      enabled,
    );
    _isDynamicColorEnabled.value = enabled;
    update(); // Notify GetBuilder widgets

    // Force app restart to apply dynamic color changes
    Get.forceAppUpdate();
  }

  void toggleTheme() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
        break;
      case ThemeMode.system:
        setTheme(ThemeMode.light);
        break;
    }
  }

  void toggleDynamicColor() {
    setDynamicColorEnabled(!_isDynamicColorEnabled.value);
  }

  /// Get the current brightness based on theme mode and system settings
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }
}
