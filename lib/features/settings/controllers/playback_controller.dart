import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/storage/local_storage.dart';

class PlaybackController extends GetxController {
  final RxBool _autoPlayEnabled = true.obs;
  final RxBool _loopVideoEnabled = false.obs;
  final RxDouble _playbackSpeed = 1.0.obs;
  final RxInt _skipDuration = 10.obs; // seconds
  final RxDouble _defaultVolume = 1.0.obs;
  final RxDouble _defaultBrightness = 0.5.obs;

  // Getters
  bool get autoPlayEnabled => _autoPlayEnabled.value;
  bool get loopVideoEnabled => _loopVideoEnabled.value;
  double get playbackSpeed => _playbackSpeed.value;
  int get skipDuration => _skipDuration.value;
  double get defaultVolume => _defaultVolume.value;
  double get defaultBrightness => _defaultBrightness.value;

  final List<double> availableSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  final List<int> availableSkipDurations = [5, 10, 15, 30, 60];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.to;

    _autoPlayEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.autoPlay) ?? true;
    _loopVideoEnabled.value =
        storage.getUserPreference<bool>(StorageKeys.loopVideo) ?? false;
    _playbackSpeed.value =
        storage.getUserPreference<double>(StorageKeys.playbackSpeed) ?? 1.0;
    _skipDuration.value =
        storage.getUserPreference<int>(StorageKeys.skipDuration) ?? 10;
    _defaultVolume.value =
        storage.getUserPreference<double>(StorageKeys.defaultVolume) ?? 1.0;
    _defaultBrightness.value =
        storage.getUserPreference<double>(StorageKeys.defaultBrightness) ?? 0.5;

    update();
  }

  Future<void> setAutoPlay(bool enabled) async {
    await StorageService.to.saveUserPreference(StorageKeys.autoPlay, enabled);
    _autoPlayEnabled.value = enabled;
    update();
  }

  Future<void> setLoopVideo(bool enabled) async {
    await StorageService.to.saveUserPreference(StorageKeys.loopVideo, enabled);
    _loopVideoEnabled.value = enabled;
    update();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.playbackSpeed,
      speed,
    );
    _playbackSpeed.value = speed;
    update();
  }

  Future<void> setSkipDuration(int duration) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.skipDuration,
      duration,
    );
    _skipDuration.value = duration;
    update();
  }

  Future<void> setDefaultVolume(double volume) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.defaultVolume,
      volume,
    );
    _defaultVolume.value = volume;
    update();
  }

  Future<void> setDefaultBrightness(double brightness) async {
    await StorageService.to.saveUserPreference(
      StorageKeys.defaultBrightness,
      brightness,
    );
    _defaultBrightness.value = brightness;
    update();
  }

  String getSpeedString(double speed) {
    if (speed == 1.0) return 'Normal';
    return '${speed}x';
  }

  String getSkipDurationString(int duration) {
    if (duration < 60) return '${duration}s';
    return '${duration ~/ 60}m';
  }
}
