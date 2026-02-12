import 'package:flutter/foundation.dart';

class AppConfig {
  // Saklar otomatis: localhost (saat ngoding) atau domain (saat di server)
  static String get baseUrl {
    if (kReleaseMode) {
      return "https://rtrw.demo.tazkia.ac.id/api";
    } else {
      return "http://localhost:5001/api";
    }
  }
}