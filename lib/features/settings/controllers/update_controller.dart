import 'package:get/get.dart';
import '../../../core/services/app_update_service.dart';

class UpdateController extends GetxController {
  final AppUpdateService _updateService = AppUpdateService.to;

  bool get isCheckingUpdate => _updateService.isCheckingUpdate;
  bool get hasUpdate => _updateService.hasUpdate;
  GitHubRelease? get latestRelease => _updateService.latestRelease;
  String get currentVersion => _updateService.currentVersion;

  @override
  void onInit() {
    super.onInit();
    // Auto-check for updates when controller initializes
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    await _updateService.checkForUpdates();
  }

  Future<void> downloadUpdate() async {
    await _updateService.downloadUpdate();
  }

  Future<void> viewReleaseNotes() async {
    await _updateService.viewReleaseNotes();
  }

  String get updateStatusText {
    if (isCheckingUpdate) {
      return 'checking_updates'.tr;
    } else if (hasUpdate) {
      return '${'update_available'.tr}: ${latestRelease?.tagName ?? 'Unknown'}';
    } else {
      return 'up_to_date'.tr;
    }
  }

  String get versionText {
    return '${'current_version'.tr}: $currentVersion';
  }
}
