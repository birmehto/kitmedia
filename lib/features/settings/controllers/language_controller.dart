import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'language_code';

  final Rx<Locale> _locale = const Locale('en').obs;
  Locale get locale => _locale.value;

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final locale = Locale(languageCode);

    if (supportedLocales.contains(locale)) {
      _locale.value = locale;
      Get.updateLocale(locale);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (supportedLocales.contains(locale)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      _locale.value = locale;
      Get.updateLocale(locale);
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }
}
