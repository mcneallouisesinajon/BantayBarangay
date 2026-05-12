import 'package:flutter/foundation.dart';

void logInfo(String message) {
  if (kDebugMode) debugPrint('[INFO] $message');
}

void logWarn(String message) {
  if (kDebugMode) debugPrint('[WARN] $message');
}

void logError(String message, [Object? error, StackTrace? stackTrace]) {
  if (kDebugMode) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}
