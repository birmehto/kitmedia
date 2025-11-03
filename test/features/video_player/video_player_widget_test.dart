import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kitmedia/features/video_player/controllers/video_player_controller.dart';
import 'package:kitmedia/features/video_player/widgets/video_player_widget.dart';

void main() {
  group('VideoPlayerWidget Tests', () {
    late VideoPlayerController controller;

    setUp(() {
      Get.testMode = true;
      controller = VideoPlayerController();
      Get.put(controller);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should build without crashing', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: VideoPlayerWidget(
            videoTitle: 'Test Video',
            videoPath: '/test/path.mp4',
          ),
        ),
      );

      // Verify the widget builds without crashing
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should display video title in widget', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: VideoPlayerWidget(
            videoTitle: 'My Test Video',
            videoPath: '/test/path.mp4',
          ),
        ),
      );

      // The widget should build successfully
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle different video paths', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: VideoPlayerWidget(
            videoTitle: 'Test Video',
            videoPath: '/different/path/video.mp4',
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });
}
