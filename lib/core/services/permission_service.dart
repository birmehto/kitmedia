import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true; // iOS and other platforms handle permissions differently
    }

    // Check current permission status
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    // Request permission if not granted
    if (status.isDenied) {
      status = await Permission.storage.request();

      if (status.isDenied) {
        // Try requesting manage external storage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }
    }

    if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    // Check manage external storage permission for Android 11+
    final manageStatus = await Permission.manageExternalStorage.status;
    return manageStatus.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
