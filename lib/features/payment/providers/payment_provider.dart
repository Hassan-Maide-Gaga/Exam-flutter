import 'package:flutter/material.dart';
import '../../../services/api/billing_api_service.dart';
import '../../../services/api/wallet_api_service.dart';
import '../../../services/storage/secure_storage.dart';

class PaymentProvider extends ChangeNotifier {
  final BillingApiService _billingApi = BillingApiService();
  final WalletApiService _walletApi = WalletApiService();
  final SecureStorage _storage = SecureStorage();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> payInvoice(String serviceName, double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final phone = await _storage.getPhone();
      if (phone == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _billingApi.payInvoice(phone, serviceName, amount);
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