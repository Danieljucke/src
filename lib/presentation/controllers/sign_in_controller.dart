import 'package:flutter/material.dart';
import '../../core/router/app_route.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entities.dart';

class SignInController extends ChangeNotifier {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Dependencies
  final AuthRepository _authRepository;
  
  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  UserEntity? _currentUser;

  SignInController({AuthRepository? authRepository}) 
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Toggle password visibility
    // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Toggle remember me
  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set current user
  void setCurrentUser(UserEntity? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Check if user is already logged in
  Future<bool> checkAuthStatus() async {
    try {
      setLoading(true);
      await _authRepository.initializeAuth();
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        setCurrentUser(user);
        return true;
      }
      return false;
    } catch (e) {
      setErrorMessage('Failed to check authentication status');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearErrorMessage();

    try {
      final result = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        rememberMe: _rememberMe,
      );

      if (result.success && result.user != null) {
        setCurrentUser(result.user);
        
        AppRouter.goToVerifyEmail(context);
      } else {
        setErrorMessage(result.error ?? 'Login failed');
      }
      
    } catch (e) {
      setErrorMessage('An error occurred during sign in: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      setErrorMessage('Google sign in not implemented yet');
    } catch (e) {
      setErrorMessage('Google sign in failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple(BuildContext context) async {
    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement Apple Sign In
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      setErrorMessage('Apple sign in not implemented yet');
    } catch (e) {
      setErrorMessage('Apple sign in failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Forgot password
  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) {
      setErrorMessage('Please enter your email address');
      return;
    }

    if (validateEmail(emailController.text) != null) {
      setErrorMessage('Please enter a valid email address');
      return;
    }

    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement forgot password logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      // Show success message or navigate to success page
      print('Password reset email sent to ${emailController.text}');
    } catch (e) {
      setErrorMessage('Failed to send password reset email: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    setLoading(true);
    
    try {
      await _authRepository.logout();
      setCurrentUser(null);
      clearErrorMessage();
      
      // Navigate to sign in page
      AppRouter.goTosignIn(context);
    } catch (e) {
      setErrorMessage('Logout failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
