import 'dart:developer' as developer;

class AppLogger {
  const AppLogger({this.name = 'ControlApp'});

  final String name;

  void info(String message, {Object? data}) {
    developer.log(message, name: name, error: data);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
