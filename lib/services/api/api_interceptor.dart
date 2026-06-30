import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiInterceptor {
  static Future<http.Response> handleResponse(http.Response response) async {
    print('📥 Status: ${response.statusCode}');
    print('📥 Headers: ${response.headers}');
    print('📥 Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Vérifier que le body est du JSON valide
      try {
        json.decode(response.body);
        return response;
      } catch (e) {
        print('❌ Invalid JSON: $e');
        throw Exception('Réponse invalide du serveur');
      }
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}