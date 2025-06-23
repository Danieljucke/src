import 'package:flutter/material.dart';
import 'package:mobile/core/router/app_route.dart';

class OTPController extends ChangeNotifier {
  // Text controllers for OTP input fields
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Focus nodes for OTP input fields
  final List<FocusNode> focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _email;
  int _resendCountdown = 0;
  bool _disposed = false; // Ajout d'un flag pour vérifier si disposed

  // Getters
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown == 0;

  // Initialize with email
  void initializeWithEmail(String email) {
    if (_disposed) return;
    _email = email;
    notifyListeners();
  }

  // Get complete OTP code
  String get otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  // Check if OTP is complete
  bool get isOTPComplete {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  // Set loading state
  void setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  // Set resending state
  void setResending(bool resending) {
    if (_disposed) return;
    _isResending = resending;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String? message) {
    if (_disposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    if (_disposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  // Handle OTP input change
  void onOTPChanged(int index, String value) {
    if (_disposed) return;
    clearErrorMessage();
        
    if (value.isNotEmpty) {
      // Move to next field if current field is filled
      if (index < 3) {
        focusNodes[index + 1].requestFocus();
      } else {
        // If last field is filled, remove focus
        focusNodes[index].unfocus();
      }
    }
        
    notifyListeners();
  }

  // Handle backspace in OTP input
  void onOTPBackspace(int index) {
    if (_disposed) return;
    if (index > 0 && otpControllers[index].text.isEmpty) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // Clear all OTP fields
  void clearOTP() {
    if (_disposed) return;
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    clearErrorMessage();
    notifyListeners();
  }

  // Start resend countdown
  void startResendCountdown() {
    if (_disposed) return;
    _resendCountdown = 60; // 60 seconds countdown
    notifyListeners();
        
    // Countdown timer avec vérification du dispose
    _runCountdown();
  }

  // Méthode séparée pour le countdown
  void _runCountdown() async {
    while (_resendCountdown > 0 && !_disposed) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_disposed && _resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      }
    }
  }

  // Verify OTP
  Future<void> verifyOTP(BuildContext context) async {
    if (_disposed) return;
    
    if (!isOTPComplete) {
      setErrorMessage('Please enter the complete OTP code');
      return;
    }

    setLoading(true);
    clearErrorMessage();

    try {
      // TODO: Implement actual OTP verification logic
      // This is where you would call your authentication service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (_disposed) return; // Vérifier après l'opération async
      
      String otp = otpCode;
            
      // For demo purposes, we'll simulate success with '1234'
      if (otp == '1234') {
        // Success - navigate to next screen
        print("OTP verified successfully");
        if (context.mounted) { // Vérifier si le context est encore valide
          AppRouter.goToHome(context);
        }
      } else {
        setErrorMessage('Invalid OTP code. Please try again.');
      }
    } catch (e) {
      if (!_disposed) {
        setErrorMessage('An error occurred during verification');
      }
    } finally {
      if (!_disposed) {
        setLoading(false);
      }
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_disposed || !canResend) return;

    setResending(true);
    clearErrorMessage();

    try {
      // TODO: Implement actual resend OTP logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (_disposed) return; // Vérifier après l'opération async
            
      print('OTP resent successfully');
      clearOTP();
      startResendCountdown();
          
    } catch (e) {
      if (!_disposed) {
        setErrorMessage('Failed to resend OTP. Please try again.');
      }
    } finally {
      if (!_disposed) {
        setResending(false);
      }
    }
  }

  // Change email
  void changeEmail() {
    // TODO: Navigate back to email input or show email change dialog
    print('Navigate to change email');
  }

  @override
  void dispose() {
    _disposed = true; // Marquer comme disposed
    
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    
    super.dispose();
  }
}
