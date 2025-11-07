import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/logger.dart';

class IntentHandlerService extends GetxService {
  static const MethodChannel _channel = MethodChannel(
    'com.kitmedia.player/intent',
  );

  final Rx<String?> sharedVideoPath = Rx<String?>(null);

  Future<IntentHandlerService> init() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _checkInitialIntent();
    return this;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onVideoReceived':
        final path = call.arguments as String?;
        if (path != null) {
          appLog('Received video from intent: $path');
          sharedVideoPath.value = path;
        }
        break;
      default:
        appLog('Unknown method: ${call.method}');
    }
  }

  Future<void> _checkInitialIntent() async {
    try {
      final path = await _channel.invokeMethod<String>('getSharedVideo');
      if (path != null && path.isNotEmpty) {
        appLog('Initial shared video: $path');
        sharedVideoPath.value = path;
      }
    } catch (e) {
      appLog('Error checking initial intent: $e');
    }
  }

  void clearSharedVideo() {
    sharedVideoPath.value = null;
  }
}
