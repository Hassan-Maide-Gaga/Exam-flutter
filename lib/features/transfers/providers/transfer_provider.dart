import 'package:flutter/material.dart';
import '../../../services/api/wallet_api_service.dart';
import '../../../services/storage/secure_storage.dart';

class TransferProvider extends ChangeNotifier {
  final WalletApiService _apiService = WalletApiService();
  final SecureStorage _storage = SecureStorage();

  String? _phone;
  double _availableBalance = 0;
  bool _isLoading = false;
  String? _error;

  String? get phone => _phone;
  double get availableBalance => _availableBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserInfo() async {
    try {
      _phone = await _storage.getPhone();
      if (_phone != null) {
        _availableBalance = await _apiService.getBalance(_phone!);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> transfer(String receiverPhone, double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final senderPhone = await _storage.getPhone();
      if (senderPhone == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _apiService.transfer(senderPhone, receiverPhone, amount);
      
      // Mettre à jour le solde
      _availableBalance = await _apiService.getBalance(senderPhone);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}