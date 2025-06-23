import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  });
  
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
  Future<void> initializeAuth();
}
