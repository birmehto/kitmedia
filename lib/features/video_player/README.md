# Video Player Feature

A modern, feature-rich video player built with `better_player_plus` and GetX state management.

## Features

### Core Functionality
- ✅ **High-quality video playback** using better_player_plus
- ✅ **Custom UI controls** with modern Material Design 3
- ✅ **Fullscreen support** with automatic orientation handling
- ✅ **Gesture controls** for seeking and volume adjustment
- ✅ **Auto-hide controls** with customizable timing
- ✅ **Position memory** - remembers playback position
- ✅ **Multiple playback speeds** (0.25x to 2.0x)
- ✅ **Volume control** with mute functionality
- ✅ **Loop video** option
- ✅ **Error handling** with detailed error messages and troubleshooting tips

### UI/UX Improvements
- 🎨 **Modern design** with smooth animations and transitions
- 🎨 **Gradient overlays** for better control visibility
- 🎨 **Haptic feedback** for better user interaction
- 🎨 **Loading states** with custom indicators
- 🎨 **Completion overlay** with replay and navigation options
- 🎨 **Settings dialog** for customizing player behavior
- 🎨 **Video info dialog** showing technical details

### Technical Features
- ⚡ **Optimized performance** with efficient state management
- ⚡ **Memory management** with proper disposal
- ⚡ **Wakelock support** to prevent screen sleep during playback
- ⚡ **System UI handling** for immersive fullscreen experience
- ⚡ **Position persistence** using SharedPreferences

## Architecture

```
lib/features/video_player/
├── controllers/
│   └── video_player_controller.dart    # Main controller with GetX
├── views/
│   └── video_player_screen.dart        # Main screen widget
├── widgets/
│   ├── video_player_widget.dart        # Core video player widget
│   └── video_error_widget.dart         # Error handling widget
├── bindings/
│   └── video_player_binding.dart       # Dependency injection
├── example_usage.dart                  # Usage examples
└── README.md                          # This file
```

## Usage

### Basic Usage

```dart
import 'package:get/get.dart';
import 'features/video_player/views/video_player_screen.dart';
import 'features/video_player/bindings/video_player_binding.dart';

// Navigate to video player
Get.to(
  () => const VideoPlayerScreen(
    videoPath: '/path/to/video.mp4',
    videoTitle: 'My Video',
  ),
  binding: VideoPlayerBinding(),
);
```

### With GetX Routing

```dart
// Define route
GetPage(
  name: '/video-player',
  page: () => const VideoPlayerScreen(
    videoPath: Get.arguments['videoPath'] ?? '',
    videoTitle: Get.arguments['videoTitle'] ?? 'Video',
  ),
  binding: VideoPlayerBinding(),
)

// Navigate
Get.toNamed('/video-player', arguments: {
  'videoPath': '/path/to/video.mp4',
  'videoTitle': 'My Video',
});
```

## Controller API

### Properties
- `isInitialized` - Whether the player is ready
- `isPlaying` - Current playback state
- `isLoading` - Loading state
- `hasError` - Error state
- `position` - Current playback position
- `duration` - Total video duration
- `progress` - Playback progress (0.0 to 1.0)
- `volume` - Current volume (0.0 to 1.0)
- `playbackSpeed` - Current playback speed
- `isFullScreen` - Fullscreen state
- `isControlsVisible` - Controls visibility state

### Methods
- `play()` - Start playback
- `pause()` - Pause playback
- `togglePlayPause()` - Toggle play/pause
- `seekTo(Duration)` - Seek to specific position
- `seekToPercentage(double)` - Seek to percentage
- `seekForward([int seconds])` - Seek forward
- `seekBackward([int seconds])` - Seek backward
- `setVolume(double)` - Set volume
- `setPlaybackSpeed(double)` - Set playback speed
- `toggleFullScreen()` - Toggle fullscreen
- `toggleControls()` - Toggle controls visibility
- `restart()` - Restart video from beginning

### Settings
- `setAutoHideControls(bool)` - Enable/disable auto-hide
- `setRememberPosition(bool)` - Enable/disable position memory
- `setLoopVideo(bool)` - Enable/disable video looping
- `setGesturesEnabled(bool)` - Enable/disable gesture controls

## Supported Formats

The player supports all formats supported by better_player_plus:
- MP4 (recommended)
- AVI
- MKV
- MOV
- WMV
- FLV
- WebM
- M4V
- 3GP
- OGV

## Dependencies

```yaml
dependencies:
  better_player_plus: ^1.1.2
  get: ^4.7.2
  shared_preferences: ^2.5.3
  wakelock_plus: ^1.4.0
  material_symbols_icons: ^4.2874.0
```

## Customization

### Theming
The player respects your app's theme and uses Material Design 3 components. Colors and styles can be customized by modifying the widget files.

### Controls
Controls can be customized by modifying the `_buildControlsOverlay` method in `video_player_widget.dart`.

### Gestures
Gesture sensitivity and behavior can be adjusted through the controller settings.

## Error Handling

The player provides comprehensive error handling with:
- Detailed error messages
- Troubleshooting tips
- Retry functionality
- Graceful fallbacks

Common errors are automatically detected and user-friendly messages are displayed.

## Performance Considerations

- The player automatically manages memory and disposes resources
- Wakelock is enabled during playback to prevent screen sleep
- Position is saved periodically to prevent data loss
- System UI is properly managed for fullscreen experience

## Migration from media_kit

If migrating from the previous media_kit implementation:

1. Replace media_kit dependencies with better_player_plus
2. Update controller initialization calls
3. The API remains largely the same for easy migration
4. Better error handling and UI improvements are included

## Contributing

When contributing to the video player feature:
1. Follow the existing architecture patterns
2. Maintain GetX state management consistency
3. Add proper error handling for new features
4. Update this README for any new functionality
5. Test on multiple video formats and devices