import 'dart:developer' as developer;

class AppLogger {
  static void log(String message, {String? tag, Object? error}) {
    final now = DateTime.now().toString();
    final logMessage = '[$now] ${tag ?? 'APP'}: $message';
    developer.log(logMessage, error: error);
  }
}
