import 'package:flutter/foundation.dart';
import 'dart:io';

class UrlHelper {
  static String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // If not running on web and URL contains localhost or 127.0.0.1
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        if (url.contains('localhost')) {
          return url.replaceAll('localhost', '10.0.2.2');
        }
        if (url.contains('127.0.0.1')) {
          return url.replaceAll('127.0.0.1', '10.0.2.2');
        }
      }
    }
    return url;
  }
}
