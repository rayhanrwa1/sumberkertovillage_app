import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pkg_logger;

//TODO : Global application logger (debug only)

class AppLogger {
  static AppLogger? _instance;
  late pkg_logger.Logger _logger;

  AppLogger._() {
    _logger = pkg_logger.Logger(
      printer: pkg_logger.PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        dateTimeFormat: pkg_logger.DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  void d(String tag, String message) {
    if (kDebugMode) {
      _logger.d('[$tag] $message');
    }
  }

  void i(String tag, String message) {
    if (kDebugMode) {
      _logger.i('[$tag] $message');
    }
  }

  void w(String tag, String message) {
    if (kDebugMode) {
      _logger.w('[$tag] $message');
    }
  }

  void e(String tag, String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
    }
  }
}
