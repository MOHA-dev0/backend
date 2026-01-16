import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  // Update with your actual local IP or emulator alias
  final String _baseUrl = '${EnvConfig.apiBaseUrl}/auth';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> checkStatus(
    String phone,
    String deviceUuid,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/check-status',
        data: {'phone': phone, 'device_uuid': deviceUuid},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode != 200) {
        throw Exception('Server Error: ${response.statusCode}');
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid Server Response (Check php.ini)');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        return e.response!.data;
      }
      throw Exception('Network Error: ${e.message} (Check php.ini)');
    }
  }

  Future<void> sendOtp(String phone) async {
    final response = await _dio.post(
      '$_baseUrl/send-otp',
      data: {'phone': phone},
      options: Options(validateStatus: (status) => status! < 500),
    );
    if (response.statusCode != 200)
      throw Exception('Server Error: ${response.statusCode}');
  }

  Future<UserModel> verifyOtp(
    String phone,
    String otp,
    String deviceUuid,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/verify-otp',
        data: {'phone': phone, 'otp': otp, 'device_uuid': deviceUuid},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode != 200)
        throw Exception('Server Error: ${response.statusCode}');
      if (response.data is! Map<String, dynamic>)
        throw Exception('Invalid Server Response');

      final token = response.data['token'];
      await _storage.write(key: 'auth_token', value: token);

      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        throw Exception(e.response!.data['message'] ?? 'Verification Failed');
      }
      throw Exception('Network Error: ${e.message} (Check Server Logs)');
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: data,
        options: Options(validateStatus: (status) => status! < 505),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return UserModel.fromJson(response.data['user']);
      }

      _handleResponseError(response);
      throw Exception('Unexpected Error'); // Should be unreachable
    } on DioException catch (e) {
      if (e.response != null) {
        _handleResponseError(e.response!);
      }
      throw Exception('Network Error: ${e.message} (Check Server Logs)');
    }
  }

  void _handleResponseError(Response response) {
    if (response.data is Map<String, dynamic>) {
      final message = response.data['message'] ?? 'Unknown Error';
      throw Exception(message);
    }
    throw Exception('Server Error: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getRegisterLookups() async {
    try {
      final response = await _dio.get(
        '${EnvConfig.apiBaseUrl}/lookups/register',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load lookups: $e');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/update-profile',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 505,
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }

      _handleResponseError(response);
      throw Exception('Unexpected Error');
    } on DioException catch (e) {
      if (e.response != null) _handleResponseError(e.response!);
      throw Exception('Network Error: ${e.message}');
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '${EnvConfig.apiBaseUrl}/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        await _storage.delete(key: 'auth_token'); // Clear invalid token
      }
      throw Exception('Network Error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> redeemVoucher(String code) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '${EnvConfig.apiBaseUrl}/wallet/redeem', // Not in /auth base url
        data: {'code': code},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 505,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      _handleResponseError(response);
      throw Exception('Unexpected Error');
    } on DioException catch (e) {
      if (e.response != null) _handleResponseError(e.response!);
      throw Exception('Network Error: ${e.message}');
    }
  }

  Future<void> verifyAccount({
    required String universityId,
    required String dob,
    required List<dynamic> documents, // List of File
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');

      FormData formData = FormData.fromMap({
        'university_id_number': universityId,
        'birth_date': dob,
      });

      for (var file in documents) {
        formData.files.add(
          MapEntry(
            'documents[]',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '$_baseUrl/verify-account',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 505,
        ),
      );

      if (response.statusCode == 200) {
        return;
      }

      _handleResponseError(response);
    } on DioException catch (e) {
      if (e.response != null) _handleResponseError(e.response!);
      throw Exception('Network Error: ${e.message}');
    }
  }
}
