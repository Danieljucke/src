import 'package:flutter/material.dart';
import 'package:mobile/core/router/app_route.dart';
import 'package:mobile/core/utils/country_mapping.dart';

class SignUpController extends ChangeNotifier {
  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final townController = TextEditingController();
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;


  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  // First name validation
  String? validateFirstName(String? value) {
    if (value?.isEmpty ?? true) return 'First name is required';
    if (value!.length < 2) return 'First name must be at least 2 characters';
    return null;
  }

  // Last name validation 
  String? validateLastName(String? value) {
    if (value?.isEmpty ?? true) return 'Last name is required';
    if (value!.length < 2) return 'Last name must be at least 2 characters';
    return null;
  }

  String? getPhoneCodeFromPhoneNumber(String? phoneNumber) {
    if (phoneNumber?.isEmpty ?? true) return null;
    
    final sanitizedNumber = phoneNumber!.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;
    final match = RegExp(r'^\d{1,3}').firstMatch(sanitizedNumber);
    return match?.group(0);
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Enter a valid email address';
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$').hasMatch(value)) return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    return null;
  }

  // Birth date validation
  String? validatebirthDate(String? value) {
    if (value?.isEmpty ?? true) return 'Birth date is required';
    
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value!)) {
      return 'Enter a valid birth date (YYYY-MM-DD)';
    }
    return null;
  }

  // Town validation
  String? validateTown(String? value) {
    if (value?.isEmpty ?? true) return 'Town is required';
    if (value!.length < 2) return 'Town must be at least 2 characters';
    return null;
  }

  // Phone number validation
  String? validatePhoneNumber(String? value) {
    if (value?.isEmpty ?? true) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value!))return 'Enter a valid phone number';
    return null;
  }  
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
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

  // Sign up with email and password
  Future<void> signUpWithEmail(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement actual authentication logic
      // This is where you would call your authentication service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call


      var country = CountryMapping().geCountryFromCountyPhoneCode(getPhoneCodeFromPhoneNumber(phoneController.text));
      
      // Check if email already exists (simulation)
      if (emailController.text == 'existing@example.com') {
        setErrorMessage('An account with this email already exists');
        return;
      }

      AppRouter.goToVerifyEmail(context);
      
      // You can add navigation logic here
      // Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      setErrorMessage('An error occurred during sign up');
    } finally {
      setLoading(false);
    }
  }  
  
  
  // Sign up with Google
  Future<void> signUpWithGoogle() async {
    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement Google Sign Up
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      print('Google sign up successful');
    } catch (e) {
      setErrorMessage('Google sign up failed');
    } finally {
      setLoading(false);
    }
  }

  // Sign up with Apple
  Future<void> signUpWithApple() async {
    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement Apple Sign Up
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      print('Apple sign up successful');
    } catch (e) {
      setErrorMessage('Apple sign up failed');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}