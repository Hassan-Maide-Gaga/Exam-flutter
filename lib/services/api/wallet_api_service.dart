import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

class WalletApiService {
  final http.Client client;

  WalletApiService({http.Client? client}) : client = client ?? http.Client();

  // Récupérer le solde
  Future<double> getBalance(String phone) async {
    try {
      final url = Uri.parse('${AppConstants.apiWallets}/$phone/balance');
      print('📡 GET Balance: $url');
      
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['balance'].toDouble();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getBalance: $e');
      rethrow;
    }
  }

  // Récupérer les transactions
  Future<List<Transaction>> getTransactions(String phone, {int page = 0, int size = 20}) async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiWallets}/$phone/transactions?page=$page&size=$size'
      );
      print('📡 GET Transactions: $url');
      
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactions = data['content'] ?? [];
        return transactions.map((t) => Transaction.fromJson(t)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getTransactions: $e');
      rethrow;
    }
  }

  // Transfert
  Future<void> transfer(String senderPhone, String receiverPhone, double amount) async {
    try {
      final url = Uri.parse('${AppConstants.apiWallets}/transfer');
      final body = json.encode({
        'senderPhone': senderPhone,
        'receiverPhone': receiverPhone,
        'amount': amount,
      });
      
      print('📡 POST Transfer: $url');
      print('📤 Body: $body');
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur transfer: $e');
      rethrow;
    }
  }

  // Dépôt
  Future<Wallet> deposit(int walletId, double amount, String paymentMethod) async {
    try {
      final url = Uri.parse('${AppConstants.apiWallets}/$walletId/deposit');
      final body = json.encode({
        'amount': amount,
        'paymentMethod': paymentMethod,
      });
      
      print('📡 POST Deposit: $url');
      print('📤 Body: $body');
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Wallet.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur deposit: $e');
      rethrow;
    }
  }

  // Retrait
  Future<Wallet> withdraw(String phone, double amount) async {
    try {
      final url = Uri.parse('${AppConstants.apiWallets}/withdraw');
      final body = json.encode({
        'phoneNumber': phone,
        'amount': amount,
      });
      
      print('📡 POST Withdraw: $url');
      print('📤 Body: $body');
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Wallet.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur withdraw: $e');
      rethrow;
    }
  }
}