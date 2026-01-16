import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_config.dart';

class AppTheme {
  static ThemeData light(AppConfig config) {
    return _buildTheme(config, Brightness.light);
  }

  static ThemeData dark(AppConfig config) {
    return _buildTheme(config, Brightness.dark);
  }

  static ThemeData _buildTheme(AppConfig config, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.primaryColor,
      brightness: brightness,
      secondary: config.secondaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData(brightness: brightness).textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
