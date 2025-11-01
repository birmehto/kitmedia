import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Global logging helper with colored output.
/// Automatically disabled in release mode.
void appLog(
  String message, {
  String tag = 'APP_LOG',
  String color = 'cyan', // default color
}) {
  // ANSI color codes
  const colors = {
    'red': '\x1B[31m',
    'green': '\x1B[32m',
    'yellow': '\x1B[33m',
    'blue': '\x1B[34m',
    'magenta': '\x1B[35m',
    'cyan': '\x1B[36m',
    'white': '\x1B[37m',
    'reset': '\x1B[0m',
  };

  final colorCode = colors[color] ?? colors['cyan'];
  final reset = colors['reset'];

  if (kDebugMode) {
    // ignore: avoid_print
    print('$colorCode[$tag] $message$reset');
  } else {
    developer.log(message, name: tag);
  }
}
