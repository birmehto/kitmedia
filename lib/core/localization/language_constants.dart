import 'package:flutter/material.dart';

/// Language configuration constants
class LanguageConstants {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('hi'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'hi': 'हिन्दी',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'hi': '🇮🇳',
  };

  static String getLanguageDisplayName(String languageCode) {
    final flag = languageFlags[languageCode] ?? '';
    final name = languageNames[languageCode] ?? 'English';
    return '$flag $name';
  }

  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }

  static bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }
}
