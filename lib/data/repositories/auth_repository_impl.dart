import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_models.dart';
import '../../core/utils/token_manager.dart';
import '../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final TokenManager _tokenManager;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    AuthDataSource? dataSource,
    TokenManager? tokenManager,
    ApiClient? apiClient,
  }) : _dataSource = dataSource ?? AuthDataSource(),
       _tokenManager = tokenManager ?? TokenManager.instance,
       _apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dataSource.login(request);
      
      // Save tokens if remember me is enabled
      await _tokenManager.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
        rememberMe: rememberMe,
      );
      
      // Set token in API client
      _apiClient.setAccessToken(response.accessToken);
      
      return AuthResult(
        success: true,
        user: UserEntity(
          id: response.user.id,
          email: response.user.email,
          firstName: response.user.firstName,
          lastName: response.user.lastName,
          isVerified: response.user.isVerified,
        ),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _tokenManager.clearTokens();
      _apiClient.clearAccessToken();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _tokenManager.hasValidToken();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await _tokenManager.getUser();
    if (user != null) {
      return UserEntity(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        isVerified: user.isVerified,
      );
    }
    return null;
  }

  @override
  Future<void> initializeAuth() async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      _apiClient.setAccessToken(token);
    }
  }
}
