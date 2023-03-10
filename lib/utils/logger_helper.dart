import 'package:logger/logger.dart';

class LoggerHelper {
  static Logger? logger;

  LoggerHelper._internal();
  factory LoggerHelper() => _instance;
  static final LoggerHelper _instance = LoggerHelper._internal();

  initLogger({
    LogFilter? filter,
    LogPrinter? printer,
    LogOutput? output,
    Level? level,
  }) {
    logger = Logger(filter: filter, printer: printer, output: output, level: level);
  }

  /// Log a message at level [Level.verbose].
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger!.log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger!.log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger!.log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger!.log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger!.log(Level.error, message, error, stackTrace);
  }
}
