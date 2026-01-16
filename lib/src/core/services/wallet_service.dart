import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/env_config.dart';

class WalletService {
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

  Future<double> redeemVoucher(String code) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$_baseUrl/wallet/redeem',
        data: {'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Returns new balance
      return double.tryParse(response.data['balance'].toString()) ?? 0.0;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Redemption Failed');
    }
  }

  Future<double> purchaseSubject(int subjectId, String accessType) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$_baseUrl/store/purchase-subject',
        data: {'subject_id': subjectId, 'access_type': accessType},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return double.tryParse(response.data['balance'].toString()) ?? 0.0;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Purchase Failed');
    }
  }
}
