import 'package:flutter/material.dart';
import 'package:mobile/presentation/controllers/verification_otp.dart';
import 'package:mobile/presentation/widgets/inputs/otp_input.dart';
import 'package:provider/provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/buttons/custom_button.dart';


class OTPPage extends StatelessWidget {
  final String email;
  
  const OTPPage({
    super.key,
    this.email = 'example@domain.com',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OTPController()..initializeWithEmail(email),
      child: const _OTPPageContent(),
    );
  }
}

class _OTPPageContent extends StatefulWidget {
  const _OTPPageContent();

  @override
  State<_OTPPageContent> createState() => _OTPPageContentState();
}

class _OTPPageContentState extends State<_OTPPageContent> {
  @override
  void initState() {
    super.initState();
    // Start countdown when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OTPController>().startResendCountdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OTPController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const AppLogo(),
                
                const SizedBox(height: 60),
                
                // Title
                
                
                // Subtitle with email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                  'Enter The OTP Code',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
                
                const SizedBox(height: 24),
                    Text(
                      'Code sent !',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'We sent the code to ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: controller.email ?? 'example@domain.com',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3AAB67),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 3,
                      height: 24,
                    ),
                  ],
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
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return OTPInputField(
                      controller: controller.otpControllers[index],
                      focusNode: controller.focusNodes[index],
                      onChanged: (value) => controller.onOTPChanged(index, value),
                      onBackspace: () => controller.onOTPBackspace(index),
                    );
                  }),
                ),
                
                const SizedBox(height: 40),
                
                // Resend code section
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Didn't receive a verification code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (controller.canResend)
                      GestureDetector(
                        onTap: controller.isResending ? null : controller.resendOTP,
                        child: Text(
                          controller.isResending ? 'Sending...' : 'Resend code',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3AAB67),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend in ${controller.resendCountdown}s',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // Login button
                CustomButton(
                  text: 'Login',
                  onPressed: () => controller.verifyOTP(context),
                  backgroundColor: const Color(0xFF3AAB67),
                  isLoading: controller.isLoading,
                  isDisabled: !controller.isOTPComplete,
                ),
                
                const SizedBox(height: 300),
                
                // Change email
                GestureDetector(
                  onTap: controller.changeEmail,
                  child: const Text(
                    'Change Email?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}