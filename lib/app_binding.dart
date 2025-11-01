import 'package:get/get.dart';

import 'core/app_state_controller.dart';
import 'features/video_list/controllers/video_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppStateController>(() => AppStateController());
    Get.lazyPut<VideoController>(() => VideoController());
  }
}
