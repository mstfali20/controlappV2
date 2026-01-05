import 'package:flutter/material.dart';

class AppNavigator {
  const AppNavigator._();

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<T?> replaceWith<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }
}
