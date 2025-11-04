import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get/get.dart';

class NetworkUtils {
  static final dio.Dio _dio = dio.Dio();
  static late CacheStore _cacheStore;
  static bool _isInitialized = false;

  /// Initialize network utilities
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize cache store
    _cacheStore = MemCacheStore();

    // Configure Dio
    _dio.options = dio.BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    // Add cache interceptor
    _dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: _cacheStore,
          // hitCacheOnErrorExcept: [401, 403], // Not available in current version
          maxStale: const Duration(days: 7),
        ),
      ),
    );

    // Add logging interceptor in debug mode
    if (Get.isLogEnable) {
      _dio.interceptors.add(
        dio.LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    _isInitialized = true;
  }

  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  /// Get connectivity status stream
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  /// Check if connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// Check if connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Download file with progress callback
  static Future<bool> downloadFile(
    String url,
    String savePath, {
    dio.ProgressCallback? onProgress,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Make GET request
  static Future<dio.Response?> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      return null;
    }
  }

  /// Make POST request
  static Future<dio.Response?> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear network cache
  static Future<void> clearCache() async {
    try {
      await _cacheStore.clean();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    try {
      // This is a simplified implementation
      // In a real app, you might want to implement proper cache size calculation
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if URL is reachable
  static Future<bool> isUrlReachable(String url) async {
    try {
      final response = await _dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get network type string
  static Future<String> getNetworkType() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'No Connection';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Create cancel token for requests
  static dio.CancelToken createCancelToken() => dio.CancelToken();

  /// Cancel all pending requests
  static void cancelAllRequests() {
    _dio.close(force: true);
  }
}
