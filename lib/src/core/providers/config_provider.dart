import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:unihub_app/src/core/constants/env_config.dart';
import '../models/app_config.dart';
import '../models/important_link.dart';

class ConfigProvider extends ChangeNotifier {
  AppConfig _config = AppConfig.defaults();
  List<ImportantLink> _links = [];
  bool _isLoading = true;

  AppConfig get config => _config;
  List<ImportantLink> get links => _links;
  bool get isLoading => _isLoading;

  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      },
    ),
  );
  static const String _prefsKey = 'app_config_cache';
  static const String _linksKey = 'app_links_cache';

  // Base URL updated for physical device access
  final String _baseUrl = EnvConfig.apiBaseUrl;

  /// Safely notify listeners using post-frame callback to avoid build-time errors
  void _safeNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadConfig() async {
    _isLoading = true;
    // Don't notify immediately during build - use safe notify

    try {
      // 1. Try to load from local cache first for immediate UI
      final prefs = await SharedPreferences.getInstance();
      final String? cachedString = prefs.getString(_prefsKey);
      final String? cachedLinks = prefs.getString(_linksKey);

      if (cachedString != null) {
        _config = AppConfig.fromJson(json.decode(cachedString));
      }

      if (cachedLinks != null) {
        final List<dynamic> jsonLinks = json.decode(cachedLinks);
        _links = jsonLinks.map((e) => ImportantLink.fromJson(e)).toList();
      }

      if (cachedString != null) {
        _isLoading = false;
        _safeNotify();
      }

      // 2. Fetch latest from API
      try {
        // Fetch Settings
        final response = await _dio.get('$_baseUrl/settings');
        if (response.statusCode == 200) {
          final newConfig = AppConfig.fromJson(response.data);
          _config = newConfig;
          await prefs.setString(_prefsKey, json.encode(response.data));
        }

        // Fetch Links
        final linksResponse = await _dio.get('$_baseUrl/links');
        if (linksResponse.statusCode == 200) {
          final List<dynamic> jsonLinks = linksResponse.data;
          _links = jsonLinks.map((e) => ImportantLink.fromJson(e)).toList();
          await prefs.setString(_linksKey, json.encode(linksResponse.data));
        }

        _safeNotify();
      } catch (e) {
        debugPrint('Failed to fetch remote config: $e');
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
      // On error, we keep the default or cached config
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }
}
