import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _phone;
  bool _isAuthenticated = false;

  String? get phone => _phone;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> checkAuth() async {
    _phone = await _storage.read(key: AppConstants.storageKeyPhone);
    _isAuthenticated = _phone != null && _phone!.isNotEmpty;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> login(String phone) async {
    try {
      await _storage.write(key: AppConstants.storageKeyPhone, value: phone);
      _phone = phone;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.storageKeyPhone);
    _phone = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}