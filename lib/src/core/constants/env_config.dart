import 'package:flutter/foundation.dart';
import 'dart:io';

class EnvConfig {
  static String get apiBaseUrl {
    // For local dev with ngrok
    return 'https://octavio-hypernatural-giancarlo.ngrok-free.dev/api';
  }
}
