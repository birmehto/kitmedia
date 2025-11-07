class AppConfig {
  // GitHub Repository Configuration
  static const String githubRepoOwner = 'birmehto';
  static const String githubRepoName = 'kitmedia';
  // Update Configuration
  static const bool enableAutoUpdateCheck = true;
  static const Duration updateCheckInterval = Duration(hours: 24);

  // App Information
  static const String appName = 'KitMedia';
  static const String appDescription = 'A Flutter media player application';
  static const int buildNumber =
      1; // This will be overridden by package_info_plus

  // UI Configuration
  static const double borderRadius = 12.0;

  // Supported Video Extensions
  static const List<String> supportedVideoExtensions = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
  ];

  // URLs
  static String get githubRepoUrl =>
      'https://github.com/$githubRepoOwner/$githubRepoName';
  static String get githubApiUrl =>
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName';
  static String get githubReleasesUrl => '$githubApiUrl/releases/latest';
}
