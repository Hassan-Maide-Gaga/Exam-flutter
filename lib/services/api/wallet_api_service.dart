import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import 'api_client.dart';

class WalletApiService {
  // Récupérer le solde
  Future<double> getBalance(String phone) async {
    try {
      final url = Uri.parse('${AppConstants.apiWallets}/$phone/balance');
      print('📡 GET Balance: $url');
      
      final response = await ApiClient.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['balance'].toDouble();
        } catch (e) {
          print('❌ Erreur parsing JSON balance: $e');
          print('📥 Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          throw Exception('Erreur de parsing du solde');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getBalance: $e');
      rethrow;
    }
  }

  // Récupérer les transactions
  Future<List<Transaction>> getTransactions(String phone, {int page = 0, int size = 10}) async {
    try {
      // ✅ Réduire la taille de la page pour éviter les réponses trop grandes
      final actualSize = size > 10 ? 10 : size;
      final url = Uri.parse(
        '${AppConstants.apiWallets}/$phone/transactions?page=$page&size=$actualSize'
      );
      print('📡 GET Transactions: $url');
      
      final response = await ApiClient.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Size: ${response.body.length} octets');

      if (response.statusCode == 200) {
        try {
          // ✅ Nettoyer la réponse avant de la parser
          String body = response.body;
          
          // Supprimer les caractères de contrôle problématiques
          body = body.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
          
          // Supprimer les séquences d'échappement Unicode problématiques
          body = body.replaceAll(RegExp(r'\\u[0-9A-Fa-f]{4}'), '');
          
          final data = json.decode(body);
          final List<dynamic> transactions = data['content'] ?? [];
          return transactions.map((t) => Transaction.fromJson(t)).toList();
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          print('📥 Response (premier 500 caractères):');
          print(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
          
          // ✅ Si parsing échoue, retourner une liste vide
          return [];
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getTransactions: $e');
      rethrow;
    }
  }

  // ✅ Nouveau: Récupérer les transactions avec pagination sur le backend
  Future<Map<String, dynamic>> getTransactionsWithPagination(String phone, {int page = 0, int size = 10}) async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiWallets}/$phone/transactions?page=$page&size=$size'
      );
      print('📡 GET Transactions (with pagination): $url');
      
      final response = await ApiClient.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        try {
          String body = response.body;
          body = body.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
          final data = json.decode(body);
          return {
            'transactions': (data['content'] as List? ?? [])
                .map((t) => Transaction.fromJson(t))
                .toList(),
            'totalElements': data['totalElements'] ?? 0,
            'totalPages': data['totalPages'] ?? 0,
            'currentPage': data['number'] ?? 0,
          };
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          return {
            'transactions': <Transaction>[],
            'totalElements': 0,
            'totalPages': 0,
            'currentPage': 0,
          };
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getTransactionsWithPagination: $e');
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
      
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');

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
      
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');

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
      
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');

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