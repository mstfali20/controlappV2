import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale("tr"),
    const Locale("en"),
  ];

  static String getFlag(String code) {
    switch (code) {
      case "en":
        return "en";
      case "tr":
        return "tr";
      // Arapça bayrağının adını buraya ekleyin
      default:
        return "tr";
    }
  }
}
