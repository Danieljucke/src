import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppConstants.primaryGreen,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryGreen,
        secondary: AppConstants.primaryOrange,
        surface: AppConstants.backgroundColor,
        background: AppConstants.backgroundColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.textPrimary,
        onBackground: AppConstants.textPrimary,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.textPrimary),
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: AppConstants.fontLarge,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontTitle,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontLarge,
          color: AppConstants.textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontMedium,
          color: AppConstants.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: AppConstants.fontSmall,
          color: AppConstants.textHint,
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppConstants.backgroundColor,
          foregroundColor: AppConstants.textSecondary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryOrange,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        hintStyle: const TextStyle(
          color: AppConstants.textHint,
          fontSize: AppConstants.fontLarge,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
          borderSide: const BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
          borderSide: const BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
          borderSide: const BorderSide(
            color: AppConstants.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppConstants.textHint,
        thickness: 1,
      ),
    );
  }
}