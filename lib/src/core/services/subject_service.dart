import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lesson_model.dart';

import 'package:unihub_app/src/core/constants/env_config.dart';

class SubjectService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      },
    ),
  );
  final String _baseUrl = EnvConfig.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<dynamic>> getSubjects() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/subjects',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load subjects');
    }
  }

  Future<List<dynamic>> getCourseTypes() async {
    try {
      final response = await _dio.get('$_baseUrl/course-types');
      return response.data;
    } catch (e) {
      debugPrint('Course Types Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getSliderAds() async {
    try {
      final response = await _dio.get('$_baseUrl/slider-ads');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return response.data;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Slider Ads Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getImportantLinks() async {
    try {
      final response = await _dio.get('$_baseUrl/links');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return response.data;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Links Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getSubjectDetails(int subjectId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/subjects/$subjectId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500, // Handle 500 manually
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Server Error: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic> &&
          response.data['data'] != null) {
        return response.data['data'];
      } else {
        throw Exception('Invalid Response Format');
      }
    } catch (e) {
      debugPrint('Subject Detail Error: $e');
      throw Exception(
        'Failed to load subject details. Please check server logs.',
      );
    }
  }

  /// Purchase subject with selected components
  Future<Map<String, dynamic>> purchaseSubject({
    required int subjectId,
    required bool buyUnits,
    required bool buyQuestions,
    required bool buyAudio,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$_baseUrl/store/purchase-subject',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
        data: {
          'subject_id': subjectId,
          'buy_units': buyUnits,
          'buy_questions': buyQuestions,
          'buy_audio': buyAudio,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'تمت عملية الشراء بنجاح',
          'balance': response.data['balance'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'فشلت العملية',
          'required': response.data['required'],
          'current': response.data['current'],
        };
      }
    } catch (e) {
      debugPrint('Purchase Error: $e');
      return {'success': false, 'message': 'حدث خطأ في الاتصال'};
    }
  }

  Future<List<dynamic>> getAcademicYears() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/academic-years',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } catch (e) {
      debugPrint('Academic Years Error: $e');
      throw Exception('Failed to load academic years');
    }
  }
}
