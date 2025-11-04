# Android Implementation Guide

This document explains the Android-specific implementations added to KitMedia.

## Overview

The Android implementation provides native functionality for:
- Advanced storage management
- MediaStore integration
- Performance optimization
- System integration

## Architecture

### 1. Platform Channel
- **Channel Name**: `com.kitmedia.player/android`
- **Location**: `lib/core/platform/android_platform.dart`
- **Native Handler**: `android/app/src/main/kotlin/com/kitmedia/player/AndroidPlatformHandler.kt`

### 2. Storage System
- **GetStorage**: Fast, lightweight local storage
- **Storage Service**: Unified storage management
- **Local Storage**: Type-safe storage containers

## Features Implemented

### Storage Management
```dart
// Get external storage directories
final directories = await AndroidPlatform.getExternalStorageDirectories();

// Check available space
final availableSpace = await AndroidPlatform.getAvailableStorageSpace();

// Check storage permissions
final hasPermissions = await AndroidPlatform.hasStoragePermissions();
```

### MediaStore Integration
```dart
// Get videos from MediaStore
final videos = await AndroidPlatform.getVideoFilesFromMediaStore();

// Add file to MediaStore
await AndroidPlatform.addToMediaStore(filePath);

// Delete from MediaStore
await AndroidPlatform.deleteFromMediaStore(filePath);
```

### Performance Features
```dart
// Enable high performance mode
await AndroidPlatform.setHighPerformanceMode(true);

// Get CPU usage
final cpuUsage = await AndroidPlatform.getCpuUsage();

// Get memory usage
final memoryInfo = await AndroidPlatform.getMemoryUsage();
```

### System Integration
```dart
// Show native toast
await AndroidPlatform.showToast('Message');

// Vibrate device
await AndroidPlatform.vibrate(duration: 100);

// Keep screen on
await AndroidPlatform.keepScreenOn(true);

// Set fullscreen mode
await AndroidPlatform.setSystemUIVisibility(true);
```

## Storage Containers

The app uses separate storage containers for different data types:

### 1. App Settings
- App version
- First launch flag
- Update check timestamps

### 2. User Preferences
- Theme settings
- Language preferences
- Playback settings
- Privacy settings

### 3. Cache Data
- Video thumbnails
- Metadata cache
- Recent files
- Temporary data

### 4. Secure Data
- User credentials
- Encryption keys
- Biometric data

## Usage Examples

### Initialize Storage
```dart
// Initialize in main.dart
await GetStorage.init();
Get.put(AppInitializationService(), permanent: true);
await AppInitializationService.to.initializeApp();
```

### Save User Preferences
```dart
final storage = StorageService.to;
await storage.saveUserPreference(StorageKeys.themeMode, 'dark');
```

### Cache Data with Expiration
```dart
await storage.saveCacheData(
  'video_metadata_${videoId}',
  metadata,
  Duration(hours: 24), // Expires in 24 hours
);
```

### Android-Specific Operations
```dart
// Check if running on Android
if (AndroidPlatform.isAndroid) {
  final videos = await storage.getVideoFilesFromMediaStore();
  // Process videos...
}
```

## Permissions Required

The following permissions are added to `AndroidManifest.xml`:

### Storage Permissions
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE` (API ≤ 29)
- `MANAGE_EXTERNAL_STORAGE` (API ≥ 30)
- `READ_MEDIA_VIDEO` (API ≥ 33)

### System Permissions
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `VIBRATE`
- `WAKE_LOCK`
- `USE_BIOMETRIC`

## File Structure

```
lib/core/
├── storage/
│   └── local_storage.dart          # GetStorage wrapper
├── services/
│   ├── storage_service.dart        # Unified storage service
│   └── app_initialization_service.dart
├── platform/
│   └── android_platform.dart      # Android platform channel
└── core.dart                       # Export file

android/app/src/main/kotlin/com/kitmedia/player/
├── MainActivity.kt                 # Main activity with method channel
└── AndroidPlatformHandler.kt       # Native Android implementations
```

## Benefits

1. **Performance**: Native Android operations for better performance
2. **Storage**: Efficient local storage with automatic cleanup
3. **Integration**: Deep Android system integration
4. **Permissions**: Proper permission handling for all Android versions
5. **MediaStore**: Direct access to Android's media database
6. **Caching**: Smart caching with expiration and cleanup

## Future Enhancements

- Background media scanning
- Advanced file operations
- Cloud storage integration
- Enhanced security features
- Performance monitoring
- Crash reporting integration

This implementation provides a solid foundation for a professional Android video player application with native performance and deep system integration.