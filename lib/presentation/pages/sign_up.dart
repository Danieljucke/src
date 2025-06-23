import 'package:flutter/material.dart';
import 'package:mobile/core/router/app_route.dart';
import 'package:provider/provider.dart';
import '../controllers/sign_up_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/buttons/social_sign_in_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignUpController(),
      child: const _SignUpPageContent(),
    );
  }
}

class _SignUpPageContent extends StatelessWidget {
  const _SignUpPageContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  
                  // Logo
                  const AppLogo(),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text(
                    'Create a no-obligation profile to discover financial products and much more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Error message
                  if (controller.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // First Name and Last Name row
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: controller.firstNameController,
                          hintText: 'First name here',
                          labelText: 'First Name',
                          validator: controller.validateFirstName,
                          onChanged: (value) => controller.clearErrorMessage(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: controller.lastNameController,
                          hintText: 'Last name here',
                          labelText: 'Last Name',
                          validator: controller.validateLastName,
                          onChanged: (value) => controller.clearErrorMessage(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: controller.phoneController,
                    hintText: '+212 777 777 777',
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhoneNumber,
                    onChanged: (value) => controller.clearErrorMessage(),
                  ),
                  
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: controller.birthDateController,
                          isDateField: true,
                          labelText: 'Birth Date',
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.datetime,
                          validator: controller.validatebirthDate,
                          onChanged: (value) => controller.clearErrorMessage(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: controller.townController,
                          hintText: 'Your Town',
                          labelText: 'Town',
                          prefixIcon: Icons.location_city_outlined,
                          validator: controller.validateTown,
                          onChanged: (value) => controller.clearErrorMessage(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Email field
                  CustomTextField(
                    controller: controller.emailController,
                    hintText: 'example@domain.com',
                    labelText: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    onChanged: (value) => controller.clearErrorMessage(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password field
                  CustomTextField(
                    controller: controller.passwordController,
                    hintText: 'Put your password here',
                    labelText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscurePassword,
                    validator: controller.validatePassword,
                    onChanged: (value) => controller.clearErrorMessage(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: const Color(0xFF3AAB67),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create button
                  CustomButton(
                    text: 'Create',
                    onPressed: () => controller.signUpWithEmail(context),
                    backgroundColor: const Color(0xFF3AAB67),
                    isLoading: controller.isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Or continue with
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0xFF9dd5b3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Or Continue with',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9dd5b3),
                          ),
                        ),
                      ),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0xFF9dd5b3),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social sign up buttons
                  SocialSignInButton(
                    text: 'Sign Up With Google',
                    onPressed: controller.isLoading 
                        ? () {} 
                        : controller.signUpWithGoogle,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SocialSignInButton(
                    text: 'Sign Up With Apple',
                    onPressed: controller.isLoading 
                        ? () {} 
                        : controller.signUpWithApple,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.isLoading ? null : () {
                          // Navigate to sign in page
                          AppRouter.goTosignIn(context);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE0A200),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  //const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}