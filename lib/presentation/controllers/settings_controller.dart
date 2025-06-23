import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDarkMode = false;

  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> logout() async {
    setLoading(true);
    try {
      // Simulate logout API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear user session, tokens, etc.
      // Navigate to login screen
      
    } catch (e) {
      // Handle logout error
      debugPrint('Logout error: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    setLoading(true);
    try {
      // Simulate delete account API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Delete user data and navigate to welcome screen
      
    } catch (e) {
      // Handle delete account error
      debugPrint('Delete account error: $e');
    } finally {
      setLoading(false);
    }
  }

  void navigateToSecurity(BuildContext context) {
    // Navigator.pushNamed(context, '/security-settings');
  }

  void navigateToGeneral(BuildContext context) {
    // Navigator.pushNamed(context, '/general-settings');
  }

  void navigateToSupport(BuildContext context) {
    // Navigator.pushNamed(context, '/customer-support');
  }

  void navigateToTerms(BuildContext context) {
    // Navigator.pushNamed(context, '/terms-of-use');
  }
}