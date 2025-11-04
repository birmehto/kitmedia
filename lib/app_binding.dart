import 'package:get/get.dart';

import 'core/app_state_controller.dart';
import 'core/services/app_update_service.dart';
import 'features/settings/controllers/playback_controller.dart';
import 'features/settings/controllers/privacy_controller.dart';
import 'features/settings/controllers/storage_controller.dart';
import 'features/video_list/controllers/video_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppStateController>(() => AppStateController());
    Get.lazyPut<VideoController>(() => VideoController());
    Get.put<AppUpdateService>(AppUpdateService(), permanent: true);

    // Settings controllers
    Get.lazyPut<StorageController>(() => StorageController());
    Get.lazyPut<PlaybackController>(() => PlaybackController());
    Get.lazyPut<PrivacyController>(() => PrivacyController());
  }
}
