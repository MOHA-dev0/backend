import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihub_app/src/core/models/system_notification.dart';
import 'package:unihub_app/src/core/models/personal_notification.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';

class NotificationService with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      },
    ),
  );
  List<SystemNotification> _notifications = [];
  List<PersonalNotification> _personalNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<SystemNotification> get notifications => _notifications;
  List<PersonalNotification> get personalNotifications =>
      _personalNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch System Notifications
      final systemResponse = await _dio.get(
        '${EnvConfig.apiBaseUrl}/notifications',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (systemResponse.statusCode == 200) {
        final data = systemResponse.data['data'] as List;
        _notifications = data
            .map((e) => SystemNotification.fromJson(e))
            .toList();
      }

      // Fetch Personal Notifications
      final personalResponse = await _dio.get(
        '${EnvConfig.apiBaseUrl}/personal-notifications',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (personalResponse.statusCode == 200) {
        final data = personalResponse.data['data'] as List;
        _personalNotifications = data
            .map((e) => PersonalNotification.fromJson(e))
            .toList();
      }

      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadStr = prefs.getString('last_notification_read_time');
    DateTime? lastReadTime;

    if (lastReadStr != null) {
      lastReadTime = DateTime.parse(lastReadStr);
    }

    if (lastReadTime == null) {
      _unreadCount = _notifications.length + _personalNotifications.length;
    } else {
      int systemUnread = _notifications
          .where((n) => n.createdAt.isAfter(lastReadTime!))
          .length;
      int personalUnread = _personalNotifications
          .where((n) => n.createdAt.isAfter(lastReadTime!))
          .length;
      _unreadCount = systemUnread + personalUnread;
    }
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_notification_read_time',
      DateTime.now().toIso8601String(),
    );
    _unreadCount = 0;
    notifyListeners();
  }
}
