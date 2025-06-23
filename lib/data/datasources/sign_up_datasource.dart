import '../models/auth_models.dart';
import '../../core/network/api_client.dart';

class SignUpDataSource {
  final ApiClient _apiClient;

  SignUpDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Sign up a new user Route: '/api/auth/register'
  
}
