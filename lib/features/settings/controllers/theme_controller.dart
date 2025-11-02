import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  static const String _dynamicColorKey = 'dynamic_color_enabled';

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
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final dynamicColorEnabled = prefs.getBool(_dynamicColorKey) ?? true;

    _themeMode.value = ThemeMode.values[themeIndex];
    _isDynamicColorEnabled.value = dynamicColorEnabled;

    update(); // Notify GetBuilder widgets
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    _themeMode.value = themeMode;
    Get.changeThemeMode(themeMode);
    update(); // Notify GetBuilder widgets
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicColorKey, enabled);
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
