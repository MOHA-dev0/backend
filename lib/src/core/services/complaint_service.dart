import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/env_config.dart';

class ComplaintService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final String _baseUrl = '${EnvConfig.apiBaseUrl}/complaints';
  final _storage = const FlutterSecureStorage();

  Future<void> submitComplaint({
    required String message,
    XFile? imageFile,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');

      FormData formData = FormData.fromMap({'message': message});

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(bytes, filename: imageFile.name),
          ),
        );
      }

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          response.data['message'] ?? 'Failed to submit complaint',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Server Error');
      }
      throw Exception('Network Error: ${e.message}');
    }
  }
}
