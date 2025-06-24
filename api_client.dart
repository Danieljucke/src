import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';  
  
  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Impossible de se connecter au serveur. Vérifiez votre connexion internet et que le serveur est démarré.');
    } on HttpException {
      throw ApiException('Erreur HTTP lors de la requête');
    } on FormatException {
      throw ApiException('Réponse du serveur invalide');
    } catch (e) {
      throw ApiException('Erreur réseau: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Impossible de se connecter au serveur. Vérifiez votre connexion internet et que le serveur est démarré.');
    } on HttpException {
      throw ApiException('Erreur HTTP lors de la requête');
    } on FormatException {
      throw ApiException('Réponse du serveur invalide');
    } catch (e) {
      throw ApiException('Erreur réseau: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Impossible de se connecter au serveur. Vérifiez votre connexion internet et que le serveur est démarré.');
    } on HttpException {
      throw ApiException('Erreur HTTP lors de la requête');
    } on FormatException {
      throw ApiException('Réponse du serveur invalide');
    } catch (e) {
      throw ApiException('Erreur réseau: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Impossible de se connecter au serveur. Vérifiez votre connexion internet et que le serveur est démarré.');
    } on HttpException {
      throw ApiException('Erreur HTTP lors de la requête');
    } on FormatException {
      throw ApiException('Réponse du serveur invalide');
    } catch (e) {
      throw ApiException('Erreur réseau: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        String errorMessage = 'Erreur de requête';
        
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
        }
        
        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Réponse du serveur invalide: ${response.body}');
    }
  }

  // Méthode pour tester la connexion
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'), // Endpoint de santé si disponible
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}