import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

class AppUpdateService extends GetxService {
  static AppUpdateService get to => Get.find();

  final Dio _dio = Dio();

  final RxBool _isCheckingUpdate = false.obs;
  final RxBool _hasUpdate = false.obs;
  final Rx<GitHubRelease?> _latestRelease = Rx<GitHubRelease?>(null);
  final RxString _currentVersion = ''.obs;

  bool get isCheckingUpdate => _isCheckingUpdate.value;
  bool get hasUpdate => _hasUpdate.value;
  GitHubRelease? get latestRelease => _latestRelease.value;
  String get currentVersion => _currentVersion.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _getCurrentVersion();
  }

  Future<void> _getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion.value = packageInfo.version;
    } catch (e) {
      // Log error silently, version will remain empty
    }
  }

  Future<void> checkForUpdates() async {
    if (_isCheckingUpdate.value) return;

    _isCheckingUpdate.value = true;

    try {
      final response = await _dio.get(
        AppConfig.githubReleasesUrl,
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode == 200) {
        final releaseData = response.data;
        final release = GitHubRelease.fromJson(releaseData);
        _latestRelease.value = release;

        // Compare versions
        _hasUpdate.value = _isNewerVersion(
          release.tagName,
          _currentVersion.value,
        );
      }
    } catch (e) {
      // Log error and show user-friendly message
      appLog(
        'update_check_failed_message'.tr,
      );
    } finally {
      _isCheckingUpdate.value = false;
    }
  }

  bool _isNewerVersion(String latestVersion, String currentVersion) {
    // Remove 'v' prefix if present
    final latest = latestVersion.replaceFirst('v', '');
    final current = currentVersion.replaceFirst('v', '');

    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    // Ensure both have same length
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }

    for (int i = 0; i < latestParts.length; i++) {
      final latestPart = latestParts[i] ?? 0;
      final currentPart = currentParts[i] ?? 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }

    return false;
  }

  Future<void> downloadUpdate() async {
    final release = _latestRelease.value;
    if (release == null) return;

    // Find APK asset
    final apkAsset = release.assets.firstWhereOrNull(
      (asset) => asset.name.toLowerCase().endsWith('.apk'),
    );

    if (apkAsset != null) {
      await _launchUrl(apkAsset.downloadUrl);
    } else {
      // Fallback to release page
      await _launchUrl(release.htmlUrl);
    }
  }

  Future<void> viewReleaseNotes() async {
    final release = _latestRelease.value;
    if (release != null) {
      await _launchUrl(release.htmlUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        appLog(
          '${'open_url_error'.tr}: $url',
        );
      }
    } catch (e) {
      appLog(
        '${'open_url_failed'.tr}: $e',
      );
    }
  }
}

class GitHubRelease {
  GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.prerelease,
    required this.publishedAt,
    required this.assets,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      tagName: json['tag_name'] ?? '',
      name: json['name'] ?? '',
      body: json['body'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      prerelease: json['prerelease'] ?? false,
      publishedAt: DateTime.parse(
        json['published_at'] ?? DateTime.now().toIso8601String(),
      ),
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map((asset) => GitHubAsset.fromJson(asset))
              .toList() ??
          [],
    );
  }

  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final bool prerelease;
  final DateTime publishedAt;
  final List<GitHubAsset> assets;
}

class GitHubAsset {
  GitHubAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    return GitHubAsset(
      name: json['name'] ?? '',
      downloadUrl: json['browser_download_url'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  final String name;
  final String downloadUrl;
  final int size;
}
