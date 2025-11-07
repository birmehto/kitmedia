import 'package:get/get.dart';

import '../app_binding.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/video_list/views/video_list_screen.dart';
import '../features/video_player/bindings/video_player_binding.dart';
import '../features/video_player/views/video_player_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String videoList = '/video-list';
  static const String videoPlayer = '/video-player';
  static const String settings = '/settings';

  // GetX routes configuration
  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => VideoListScreen(),
      binding: AppBindings(),
      transition: Transition.fade,
    ),
    GetPage(
      name: videoList,
      page: () => VideoListScreen(),
      binding: AppBindings(),
      transition: Transition.fade,
    ),
    GetPage(
      name: videoPlayer,
      page: () => VideoPlayerScreen(
        videoPath: Get.parameters['videoPath'] ?? '',
        videoTitle: Get.parameters['videoTitle'] ?? 'Video',
      ),
      transition: Transition.rightToLeft,
      binding: VideoPlayerBinding(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.downToUp,
    ),
  ];

  // Navigation helpers
  static void navigateToVideoList() {
    Get.toNamed(videoList);
  }

  static void navigateToVideoPlayer({
    required String videoPath,
    required String videoTitle,
  }) {
    Get.toNamed(
      videoPlayer,
      parameters: {'videoPath': videoPath, 'videoTitle': videoTitle},
    );
  }

  static void navigateToSettings() {
    Get.toNamed(settings);
  }

  static void goBack() {
    if (Get.currentRoute != home) {
      Get.back();
    } else {
      Get.offAllNamed(home);
    }
  }

  // Push navigation (keeps current route in stack)
  static void pushVideoPlayer({
    required String videoPath,
    required String videoTitle,
  }) {
    Get.toNamed(
      videoPlayer,
      parameters: {'videoPath': videoPath, 'videoTitle': videoTitle},
    );
  }

  static void pushSettings() {
    Get.toNamed(settings);
  }
}
