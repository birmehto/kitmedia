import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/language_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/storage/local_storage.dart';

class LanguageController extends GetxController {
  final Rx<Locale> _locale = const Locale('en').obs;
  Locale get locale => _locale.value;

  List<Locale> get supportedLocales => LanguageConstants.supportedLocales;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final storage = StorageService.to;
    final languageCode =
        storage.getUserPreference<String>(StorageKeys.languageCode) ?? 'en';
    final locale = Locale(languageCode);

    if (LanguageConstants.isSupported(locale)) {
      _locale.value = locale;
      Get.updateLocale(locale);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (LanguageConstants.isSupported(locale)) {
      await StorageService.to.saveUserPreference(
        StorageKeys.languageCode,
        locale.languageCode,
      );
      _locale.value = locale;
      Get.updateLocale(locale);
    }
  }

  String getLanguageName(String languageCode) {
    return LanguageConstants.getLanguageName(languageCode);
  }

  String getLanguageDisplayName(String languageCode) {
    return LanguageConstants.getLanguageDisplayName(languageCode);
  }
}
