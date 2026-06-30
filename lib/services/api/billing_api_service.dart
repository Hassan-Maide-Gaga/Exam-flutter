import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../models/facture.dart';

class BillingApiService {
  final http.Client client;

  BillingApiService({http.Client? client}) : client = client ?? http.Client();

  // Récupérer les factures du mois en cours
  Future<List<Facture>> getCurrentMonthFactures(String walletCode, {String? unite}) async {
    String url = '${AppConstants.apiExternal}/factures/$walletCode/current';
    if (unite != null && unite.isNotEmpty) {
      url += '?unite=$unite';
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((f) => Facture.fromJson(f)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  // Payer des factures
  Future<void> payFactures(String phone, List<String> references) async {
    final response = await client.post(
      Uri.parse('${AppConstants.apiWallets}/pay-factures'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': phone,
        'factureReferences': references,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du paiement des factures');
    }
  }

  // Payer une facture
  Future<void> payInvoice(String phone, String serviceName, double amount) async {
    final response = await client.post(
      Uri.parse('${AppConstants.apiWallets}/pay'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': phone,
        'serviceName': serviceName,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du paiement de la facture');
    }
  }
}