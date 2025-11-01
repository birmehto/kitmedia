import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_state.dart';

class AppStateController extends GetxController {
  final Rx<ScanStatus> _scanStatus = ScanStatus.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasStoragePermission = false.obs;
  final Rx<Locale> _locale = const Locale('en').obs;

  ScanStatus get scanStatus => _scanStatus.value;
  String get errorMessage => _errorMessage.value;
  bool get hasStoragePermission => _hasStoragePermission.value;
  Locale get locale => _locale.value;

  void setScanStatus(ScanStatus status) {
    _scanStatus.value = status;
  }

  void setError(String? error) {
    _errorMessage.value = error ?? '';
    if (error != null) {
      _scanStatus.value = ScanStatus.error;
    } else {
      _scanStatus.value = ScanStatus.idle;
    }
  }

  void setStoragePermission(bool hasPermission) {
    _hasStoragePermission.value = hasPermission;
  }

  void setLocale(Locale locale) {
    _locale.value = locale;
    Get.updateLocale(locale);
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
