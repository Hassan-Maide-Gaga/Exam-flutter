import 'package:flutter/material.dart';
import '../../../models/facture.dart';
import '../../../services/api/billing_api_service.dart';
import '../../../services/api/wallet_api_service.dart';
import '../../../services/storage/secure_storage.dart';

class BillsProvider extends ChangeNotifier {
  final BillingApiService _billingApi = BillingApiService();
  final WalletApiService _walletApi = WalletApiService();
  final SecureStorage _storage = SecureStorage();

  List<Facture> _bills = [];
  List<Facture> _selectedBills = [];
  bool _isLoading = false;
  String? _error;
  String _currentFilter = '';

  List<Facture> get bills => _bills;
  List<Facture> get selectedBills => _selectedBills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSelectedAmount {
    return _selectedBills.fold(0, (sum, bill) => sum + bill.amount);
  }

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final phone = await _storage.getPhone();
      if (phone == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer le wallet code
      final walletCode = 'WLT-0000001'; // À remplacer par la vraie récupération
      
      final bills = await _billingApi.getCurrentMonthFactures(
        walletCode,
        unite: _currentFilter.isEmpty ? null : _currentFilter,
      );

      _bills = bills.where((b) => !b.paid).toList();
      _selectedBills.clear();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(Facture bill) {
    if (_selectedBills.contains(bill)) {
      _selectedBills.remove(bill);
    } else {
      _selectedBills.add(bill);
    }
    notifyListeners();
  }

  bool isSelected(Facture bill) {
    return _selectedBills.contains(bill);
  }

  void filterByProvider(String provider) {
    _currentFilter = provider;
    loadBills();
  }

  Future<bool> paySelectedBills() async {
    if (_selectedBills.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final phone = await _storage.getPhone();
      if (phone == null) {
        throw Exception('Utilisateur non connecté');
      }

      final references = _selectedBills.map((b) => b.reference).toList();
      await _billingApi.payFactures(phone, references);

      _selectedBills.clear();
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