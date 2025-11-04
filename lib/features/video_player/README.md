# Enhanced Video Player

A comprehensive, feature-rich video player for Flutter with modern UI and advanced controls.

## 🚀 Features

### Core Functionality
- **High-quality video playback** using Better Player Plus
- **Gesture controls** for brightness and volume adjustment
- **Fullscreen mode** with automatic orientation handling
- **Playback speed control** (0.25x to 2x speed)
- **Loop and repeat** functionality
- **Auto-hide controls** with customizable timing

### Advanced Features
- **Playlist support** with next/previous navigation
- **Screenshot capture** with automatic saving
- **Subtitle support** (SRT format)
- **Video quality selection** (when multiple qualities available)
- **Picture-in-picture mode** (platform dependent)
- **Remember playback position** across sessions
- **Wakelock integration** to prevent screen sleep

### UI/UX Enhancements
- **Modern Material 3 design** with smooth animations
- **Gradient overlays** for better control visibility
- **Responsive controls** that adapt to screen size
- **Error handling** with detailed error messages and recovery options
- **Loading states** with progress indicators
- **Gesture feedback** with visual indicators

## 📱 Usage

### Basic Usage

```dart
import 'package:get/get.dart';
import 'package:kitmedia/features/video_player/views/video_player_screen.dart';
import 'package:kitmedia/features/video_player/bindings/video_player_binding.dart';

// Navigate to video player
Get.to(
  () => VideoPlayerScreen(
    videoPath: '/path/to/your/video.mp4',
    videoTitle: 'My Video Title',
  ),
  binding: VideoPlayerBinding(),
);
```

### Advanced Usage with Playlist

```dart
// Set up playlist
final videoPaths = [
  '/path/to/video1.mp4',
  '/path/to/video2.mp4',
  '/path/to/video3.mp4',
];

Get.to(
  () => VideoPlayerScreen(
    videoPath: videoPaths.first,
    videoTitle: 'Video 1',
  ),
  binding: VideoPlayerBinding(),
);

// Configure playlist after navigation
WidgetsBinding.instance.addPostFrameCallback((_) {
  final controller = Get.find<VideoPlayerController>(tag: videoPaths.first);
  controller.setPlaylist(videoPaths, startIndex: 0);
});
```

### Programmatic Control

```dart
final controller = Get.find<VideoPlayerController>(tag: videoPath);

// Playback controls
controller.play();
controller.pause();
controller.togglePlay();
controller.seek(Duration(minutes: 2));
controller.setSpeed(1.5);

// Settings
controller.setVolume(0.8);
controller.setBrightness(0.6);
controller.setLoop(true);
controller.setGesturesEnabled(true);

// Playlist navigation
controller.nextVideo();
controller.previousVideo();

// Screenshot
controller.takeScreenshot();
```

## 🎮 Controls

### Touch Gestures
- **Single tap**: Toggle controls visibility
- **Double tap**: Play/pause video
- **Swipe left side**: Adjust brightness
- **Swipe right side**: Adjust volume
- **Pinch to zoom**: (Future feature)

### Control Buttons
- **Play/Pause**: Center button or bottom controls
- **Seek**: ±10 seconds with dedicated buttons
- **Fullscreen**: Toggle fullscreen mode
- **Screenshot**: Capture current frame
- **Playlist**: View and navigate playlist
- **Settings**: Access video options menu

### Settings Menu
- **Playback Speed**: 0.25x, 0.5x, 0.75x, 1x, 1.25x, 1.5x, 1.75x, 2x
- **Volume Control**: System volume integration
- **Video Info**: Resolution, duration, codec information
- **Loop Mode**: Toggle video looping
- **Gesture Controls**: Enable/disable gesture controls

## 🏗️ Architecture

### File Structure
```
lib/features/video_player/
├── bindings/
│   └── video_player_binding.dart
├── controllers/
│   └── video_player_controller.dart
├── views/
│   └── video_player_screen.dart
├── widgets/
│   ├── video_player_widget.dart
│   ├── video_error_widget.dart
│   ├── video_playlist_widget.dart
│   ├── video_subtitle_widget.dart
│   └── video_quality_widget.dart
├── utils/
│   └── video_player_utils.dart
├── theme/
│   └── video_player_theme.dart
└── example/
    └── video_player_example.dart
```

### Key Components

#### VideoPlayerController
- Manages video playback state and controls
- Handles gesture interactions
- Manages playlist and navigation
- Integrates with system volume and brightness

#### VideoPlayerWidget
- Main video display component
- Gesture detection and handling
- Control overlay management
- Animation and transition handling

#### VideoPlayerScreen
- Screen wrapper with lifecycle management
- Error handling and recovery
- Screenshot functionality
- System UI integration

## 🎨 Theming

The video player uses a comprehensive theming system defined in `VideoPlayerTheme`:

```dart
// Custom colors
VideoPlayerTheme.primaryColor
VideoPlayerTheme.backgroundColor
VideoPlayerTheme.controlsActive

// Text styles
VideoPlayerTheme.titleStyle
VideoPlayerTheme.subtitleStyle

// Button styles
VideoPlayerTheme.primaryButtonStyle
VideoPlayerTheme.secondaryButtonStyle

// Decorations
VideoPlayerTheme.controlsDecoration
VideoPlayerTheme.overlayDecoration
```

## 🔧 Configuration

### Dependencies
Add these to your `pubspec.yaml`:

```yaml
dependencies:
  better_player_plus: ^1.1.2
  get: ^4.7.2
  material_symbols_icons: ^4.2874.0
  screen_brightness: ^2.1.7
  volume_controller: ^3.4.0
  wakelock_plus: ^1.4.0
  shared_preferences: ^2.5.3
  path_provider: ^2.1.5
```

### Permissions
Add these permissions to your platform-specific configuration:

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to save video screenshots</string>
```

## 🚀 Performance Optimizations

- **Lazy loading** of video resources
- **Memory management** with proper disposal
- **Efficient gesture handling** with debouncing
- **Optimized animations** using Flutter's animation framework
- **Background processing** for thumbnail generation

## 🐛 Error Handling

The video player includes comprehensive error handling:

- **Network errors**: Retry mechanisms and user feedback
- **File not found**: Clear error messages and navigation options
- **Codec issues**: Format compatibility warnings
- **Permission errors**: Guidance for enabling required permissions
- **Playback errors**: Automatic recovery attempts

## 🔮 Future Enhancements

- **Chromecast support**: Cast videos to external displays
- **AirPlay integration**: iOS screen mirroring
- **Advanced subtitle features**: Multiple languages, styling
- **Video filters**: Brightness, contrast, saturation adjustments
- **Streaming support**: HLS and DASH adaptive streaming
- **Chapter navigation**: Video chapter markers
- **Thumbnail preview**: Seek bar thumbnail previews
- **Audio track selection**: Multiple audio tracks
- **Closed captions**: Accessibility improvements

## 📄 License

This video player is part of the KitMedia project and follows the same licensing terms.

## 🤝 Contributing

Contributions are welcome! Please follow the existing code style and add tests for new features.

## 📞 Support

For issues and feature requests, please use the project's issue tracker.