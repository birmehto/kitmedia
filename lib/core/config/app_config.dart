class AppConfig {
  static const String appName = 'KitMedia Player';
  static const String appVersion = '1.0.0';

  // Supported video formats
  static const List<String> supportedVideoExtensions = [
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
    '.3gp',
    '.3gpp',
    '.mts',
    '.ts',
    '.mpg',
    '.mpeg',
    '.mp2',
    '.mpe',
    '.mpv',
    '.m2v',
    '.m4p',
    '.m4b',
    '.divx',
    '.xvid',
    '.asf',
    '.rm',
    '.rmvb',
    '.vob',
    '.ogv',
    '.drc',
    '.gif', // Animated GIFs
    '.mxf',
    '.roq',
    '.nsv',
  ];

  // Performance settings
  static const int maxConcurrentScans = 3;
  static const Duration scanTimeout = Duration(seconds: 30);

  // UI settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}
