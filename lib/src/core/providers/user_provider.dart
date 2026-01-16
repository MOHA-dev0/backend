import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
  }

  Future<void> refreshUser() async {
    // if (_user == null) return; // REMOVED: Allow fetching user if token exists but _user is null (Restoration)
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      if (e.toString().contains('401')) {
        logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> redeemCode(String code) async {
    try {
      final response = await _authService.redeemVoucher(code);
      // Response includes new balance?
      // "balance": 1000
      if (response['balance'] != null) {
        if (_user != null) {
          _user = _user!.copyWith(
            balance: double.tryParse(response['balance'].toString()) ?? 0.0,
          );
          notifyListeners();
        }
      } else {
        await refreshUser();
      }
      return null; // Success
    } catch (e) {
      return e.toString().replaceAll('Exception:', '').trim();
    }
  }

  /// Update user balance after purchase
  void updateBalance(double newBalance) {
    if (_user != null) {
      _user = _user!.copyWith(balance: newBalance);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage(); // Create instance
    await storage.delete(key: 'auth_token'); // Clear Token
    _user = null;
    notifyListeners();
  }
}
