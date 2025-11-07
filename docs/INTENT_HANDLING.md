# Video Intent Handling

This document explains how the app handles video files opened from external sources (file managers, browsers, etc.).

## Features

- App appears in "Open with" dialog when users tap on video files
- Supports all common video formats (mp4, mkv, avi, mov, etc.)
- Handles both VIEW and SEND intents
- Automatic video playback when opened from external apps

## How It Works

### 1. Android Manifest Configuration

The app registers intent filters in `AndroidManifest.xml` to handle:
- `ACTION_VIEW` - When user opens a video file
- `ACTION_SEND` - When user shares a video to the app

### 2. Intent Handler Service

The `IntentHandlerService` manages incoming video intents:
- Receives video file paths from Android
- Notifies the app when a new video is received
- Provides reactive stream for listening to shared videos

### 3. Usage in Your App

#### Option 1: Using IntentVideoHandler Widget

Wrap your main screen with `IntentVideoHandler`:

```dart
import 'package:kitmedia/core/widgets/intent_video_handler.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntentVideoHandler(
      onVideoReceived: (String videoPath) {
        // Handle the received video
        // For example, navigate to video player
        Get.toNamed(
          AppRoutes.videoPlayer,
          arguments: {'videoPath': videoPath},
        );
      },
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

#### Option 2: Manual Listening

Listen to the intent service directly in your controller:

```dart
import 'package:get/get.dart';
import 'package:kitmedia/core/services/intent_handler_service.dart';

class VideoListController extends GetxController {
  final _intentService = Get.find<IntentHandlerService>();

  @override
  void onInit() {
    super.onInit();
    
    // Listen for shared videos
    ever(_intentService.sharedVideoPath, (String? path) {
      if (path != null) {
        _handleSharedVideo(path);
        _intentService.clearSharedVideo();
      }
    });
  }

  void _handleSharedVideo(String path) {
    // Play the video or add to list
    print('Received video: $path');
  }
}
```

## Testing

1. Build and install the app
2. Open a file manager (e.g., Files by Google)
3. Navigate to a video file
4. Tap on the video
5. Select "KitMedia" from the "Open with" dialog
6. The app should open and handle the video

## Supported Video Formats

- MP4 (.mp4)
- MKV (.mkv)
- AVI (.avi)
- MOV (.mov)
- WMV (.wmv)
- FLV (.flv)
- WebM (.webm)
- M4V (.m4v)
- 3GP (.3gp)
- MPEG (.mpeg, .mpg)

## Notes

- The app must be installed and have proper permissions
- Video files must be accessible (not in restricted directories)
- The intent handler is initialized automatically on app startup
