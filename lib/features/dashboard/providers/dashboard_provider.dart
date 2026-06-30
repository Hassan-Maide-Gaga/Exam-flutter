import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../services/api/wallet_api_service.dart';
import '../../../services/storage/secure_storage.dart';

class DashboardProvider extends ChangeNotifier {
  final WalletApiService _apiService = WalletApiService();
  final SecureStorage _storage = SecureStorage();

  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  bool _isBalanceVisible = true;

  double get balance => _balance;
  List<Transaction> get recentTransactions => _transactions.take(5).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBalanceVisible => _isBalanceVisible;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final phone = await _storage.getPhone();
      if (phone == null) {
        throw Exception('Utilisateur non connecté');
      }

      final balance = await _apiService.getBalance(phone);
      final transactions = await _apiService.getTransactions(phone, page: 0, size: 10);

      _balance = balance;
      _transactions = transactions;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    try {
      final phone = await _storage.getPhone();
      if (phone != null) {
        _balance = await _apiService.getBalance(phone);
        notifyListeners();
      }
    } catch (e) {
      // Ignorer
    }
  }
}