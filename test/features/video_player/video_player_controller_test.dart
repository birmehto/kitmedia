import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kitmedia/features/video_player/controllers/video_player_controller.dart';

void main() {
  group('VideoPlayerController Tests', () {
    late VideoPlayerController controller;

    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
      controller = VideoPlayerController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with default values', () {
      expect(controller.isInitialized, false);
      expect(controller.isPlaying, false);
      expect(controller.isLoading, false);
      expect(controller.hasError, false);
      expect(controller.volume, 1.0);
      expect(controller.playbackSpeed, 1.0);
      expect(controller.position, Duration.zero);
      expect(controller.duration, Duration.zero);
      expect(controller.progress, 0.0);
    });

    test('should calculate progress correctly', () {
      // Mock duration and position
      controller.onInit();

      // Test with zero duration
      expect(controller.progress, 0.0);

      // Note: We can't easily test with actual values without mocking
      // the better_player_plus controller, which would require more setup
    });

    test('should have correct available speeds', () {
      expect(
        controller.availableSpeeds,
        [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
      );
    });

    test('should handle settings correctly', () {
      // Test auto-hide controls
      expect(controller.autoHideControls, true);
      controller.setAutoHideControls(false);
      expect(controller.autoHideControls, false);

      // Test remember position
      expect(controller.rememberPosition, true);
      controller.setRememberPosition(false);
      expect(controller.rememberPosition, false);

      // Test loop video
      expect(controller.loopVideo, false);
      controller.setLoopVideo(true);
      expect(controller.loopVideo, true);

      // Test gestures enabled
      expect(controller.gesturesEnabled, true);
      controller.setGesturesEnabled(false);
      expect(controller.gesturesEnabled, false);
    });

    test('should handle volume correctly', () {
      // Test setting volume
      controller.setVolume(0.5);
      expect(controller.volume, 0.5);

      // Test volume clamping
      controller.setVolume(1.5);
      expect(controller.volume, 1.0);

      controller.setVolume(-0.5);
      expect(controller.volume, 0.0);
    });

    test('should handle playback speed correctly', () {
      controller.setPlaybackSpeed(1.5);
      expect(controller.playbackSpeed, 1.5);
    });

    test('should handle controls visibility', () {
      expect(controller.isControlsVisible, true);

      controller.hideControls();
      expect(controller.isControlsVisible, false);

      controller.showControls();
      expect(controller.isControlsVisible, true);

      controller.toggleControls();
      expect(controller.isControlsVisible, false);
    });

    test('should handle fullscreen state', () {
      expect(controller.isFullScreen, false);

      // Note: toggleFullScreen() calls system methods that can't be easily tested
      // without mocking the SystemChrome class
    });
  });
}
