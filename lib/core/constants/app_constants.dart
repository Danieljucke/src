import 'package:flutter/material.dart';

class AppConstants {
  // App Colors
  static const Color primaryGreen = Color(0xFF3AAB67);
  static const Color primaryOrange = Color(0xFFE0A200);
  static const Color backgroundColor = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;
  static const Color textHint = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF666666);
  static const Color textinfo = Color(0xFF333333);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color errorColor = Colors.red;

  // Border Radius
  static const double buttonRadius = 16.0;
  static const double buttonSettingsRadius = 20.0;
  static const double textFieldRadius = 25.0;
  static const double cardRadius = 12.0;

  // Padding and Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXLarge = 53.0;

  // Font Sizes
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 24.0;
  static const double fontTitle = 28.0;
  static const double fontBalance = 42.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // App Strings
  static const String appName = 'Wallet Africa';
  static const String welcomeMessage = 'Send and receive money securely, quickly and without borders. Wallet Africa goes with you, wherever you are.';
  
  // Form Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  
  // Button Texts
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String next = 'Next';
  static const String forgotPassword = 'Forget Password?';
  static const String rememberMe = 'Reminded me';
  static const String signInWithGoogle = 'Sign In With Google';
  static const String signInWithApple = 'Sign In With Apple';
  static const String orContinueWith = 'Or Continue with';
  static const String dontHaveAccount = "Don't have any account? ";
  
  // Hint Texts
  static const String emailHint = 'example@domain.com';
  static const String passwordHint = 'Put your password here';
  
  // Labels
  static const String emailLabel = 'Email Address';
  static const String passwordLabel = 'Password';
}