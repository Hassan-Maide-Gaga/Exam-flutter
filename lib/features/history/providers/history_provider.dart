import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../services/api/wallet_api_service.dart';
import '../../../services/storage/secure_storage.dart';

class HistoryProvider extends ChangeNotifier {
  final WalletApiService _apiService = WalletApiService();
  final SecureStorage _storage = SecureStorage();

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'ALL';

  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 0;
      _transactions.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final phone = await _storage.getPhone();
      if (phone == null) {
        throw Exception('Utilisateur non connecté');
      }

      final newTransactions = await _apiService.getTransactions(
        phone,
        page: _currentPage,
        size: 20,
      );

      if (newTransactions.isEmpty) {
        _hasMore = false;
      } else {
        _transactions.addAll(newTransactions);
        _currentPage++;
        _hasMore = newTransactions.length == 20;
      }

      _applyFilter();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilter() {
    if (_currentFilter == 'ALL') {
      _filteredTransactions = List.from(_transactions);
    } else {
      _filteredTransactions = _transactions
          .where((t) => t.type.toString().split('.').last == _currentFilter)
          .toList();
    }
    notifyListeners();
  }

  void filterByType(String type) {
    _currentFilter = type;
    _applyFilter();
  }

  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await loadHistory(refresh: false);
    }
  }
}