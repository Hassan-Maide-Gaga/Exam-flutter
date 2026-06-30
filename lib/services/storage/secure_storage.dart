import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> savePhone(String phone) async {
    await _storage.write(key: AppConstants.storageKeyPhone, value: phone);
  }

  Future<String?> getPhone() async {
    return await _storage.read(key: AppConstants.storageKeyPhone);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.storageKeyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.storageKeyToken);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}