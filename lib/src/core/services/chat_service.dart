import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';

class ChatService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      },
    ),
  );
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = EnvConfig.apiBaseUrl;

  Future<List<dynamic>> getMessages() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$_baseUrl/chat/messages',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage(String message) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/chat/messages',
        data: {'message': message},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
