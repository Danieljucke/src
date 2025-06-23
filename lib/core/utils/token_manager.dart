import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/auth_models.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _tokenExpiryKey = 'token_expiry';

  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();
  
  TokenManager._();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required User user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_userKey, json.encode(user.toJson()));
      await prefs.setBool(_rememberMeKey, true);
      
      // Set token expiry (assuming 24 hours for access token)
      final expiry = DateTime.now().add(const Duration(hours: 24));
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    } else {
      // Clear any existing tokens if remember me is false
      await clearTokens();
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (!rememberMe) return null;
    
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, clear it
        await clearTokens();
        return null;
      }
    }
    
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (!rememberMe) return null;
    
    return prefs.getString(_refreshTokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (!rememberMe) return null;
    
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      final userData = json.decode(userString);
      return User.fromJson(userData);
    }
    return null;
  }

  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_tokenExpiryKey);
  }

  Future<void> updateTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }
}
