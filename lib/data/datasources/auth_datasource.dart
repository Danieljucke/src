import '../models/auth_models.dart';
import '../../core/network/api_client.dart';

class AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post('/api/auth/login', request.toJson());
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/api/auth/logout', {});
    } catch (e) {
      // Handle logout error if needed
      rethrow;
    }
  }

  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post('/api/auth/refresh', {
        'refresh_token': refreshToken,
      });
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
