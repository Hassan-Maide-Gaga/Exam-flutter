import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ApiClient {
  static const int connectionTimeout = 60; // secondes
  static const int receiveTimeout = 60;
  static const int maxResponseSize = 10 * 1024 * 1024; // 10 MB

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final client = http.Client();
    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: connectionTimeout));
      
      // ✅ Vérifier la taille de la réponse
      if (response.body.length > maxResponseSize) {
        print('⚠️ Réponse trop grande: ${response.body.length} octets');
      }
      
      return response;
    } on TimeoutException {
      throw Exception('La requête a pris trop de temps');
    } finally {
      client.close();
    }
  }

  static Future<http.Response> post(Uri url,
      {Map<String, String>? headers, body}) async {
    final client = http.Client();
    try {
      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: connectionTimeout));
      return response;
    } on TimeoutException {
      throw Exception('La requête a pris trop de temps');
    } finally {
      client.close();
    }
  }
}