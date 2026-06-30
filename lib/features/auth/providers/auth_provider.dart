import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _phone;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  String? get phone => _phone;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _phone = await _storage.read(key: AppConstants.storageKeyPhone);
      _isAuthenticated = _phone != null && _phone!.isNotEmpty;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _isAuthenticated;
  }

  Future<bool> login(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (phone.isEmpty || !phone.startsWith('+221')) {
        throw Exception('Numéro de téléphone invalide');
      }

      await _storage.write(key: AppConstants.storageKeyPhone, value: phone);
      _phone = phone;
      _isAuthenticated = true;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🚪 Déconnexion complète
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Supprimer toutes les données stockées
      await _storage.delete(key: AppConstants.storageKeyPhone);
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'remember_phone');
      
      // Réinitialiser l'état
      _phone = null;
      _isAuthenticated = false;
      _error = null;
      
      print('✅ Déconnexion réussie');
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur déconnexion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 Rafraîchir l'état d'authentification
  Future<void> refreshAuth() async {
    await checkAuth();
  }
}