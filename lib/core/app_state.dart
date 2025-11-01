import 'package:flutter/material.dart';

/// Represents the scanning and app configuration state.
@immutable
class AppState {
  const AppState({
    this.scanStatus = ScanStatus.idle,
    this.errorMessage,
    this.hasStoragePermission = false,
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  final ScanStatus scanStatus;
  final String? errorMessage;
  final bool hasStoragePermission;
  final ThemeMode themeMode;
  final Locale locale;

  AppState copyWith({
    ScanStatus? scanStatus,
    String? errorMessage,
    bool? hasStoragePermission,
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppState(
      scanStatus: scanStatus ?? this.scanStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      hasStoragePermission: hasStoragePermission ?? this.hasStoragePermission,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.scanStatus == scanStatus &&
        other.errorMessage == errorMessage &&
        other.hasStoragePermission == hasStoragePermission &&
        other.themeMode == themeMode &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(
    scanStatus,
    errorMessage,
    hasStoragePermission,
    themeMode,
    locale,
  );

  @override
  String toString() {
    return 'AppState('
        'scanStatus: $scanStatus, '
        'errorMessage: $errorMessage, '
        'hasStoragePermission: $hasStoragePermission, '
        'themeMode: $themeMode, '
        'locale: $locale'
        ')';
  }
}

/// Represents current scan status of the app.
enum ScanStatus { idle, scanning, completed, error }
