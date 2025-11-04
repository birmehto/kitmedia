import 'package:get/get.dart';

import '../controllers/language_controller.dart';
import '../controllers/playback_controller.dart';
import '../controllers/privacy_controller.dart';
import '../controllers/storage_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/update_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Core controllers (permanent)
    Get.put(LanguageController(), permanent: true);
    Get.put(ThemeController(), permanent: true);

    // Feature controllers (lazy)
    Get.lazyPut(() => PlaybackController());
    Get.lazyPut(() => StorageController());
    Get.lazyPut(() => PrivacyController());
    Get.lazyPut(() => UpdateController());
  }
}
