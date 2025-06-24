import 'package:flutter/material.dart';
import 'package:mobile/presentation/pages/beneficiaries_page.dart';
import 'package:mobile/presentation/pages/exchange_page.dart';
import 'package:mobile/presentation/pages/get_started.dart';
import 'package:mobile/presentation/pages/historical_page.dart';
import 'package:mobile/presentation/pages/home.dart';
import 'package:mobile/presentation/pages/notification_page.dart';
import 'package:mobile/presentation/pages/otp_check.dart';
import 'package:mobile/presentation/pages/profile_page.dart';
import 'package:mobile/presentation/pages/settings_page.dart';
import 'package:mobile/presentation/pages/sign_in.dart';
import 'package:mobile/presentation/pages/sign_up.dart';
import 'package:mobile/presentation/pages/started.dart';

class AppRouter {
  // Définition des routes
  static const String splash = '/';
  static const String getStarted = '/landing';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String forgotPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';
  static const String verifyEmail = '/verifyEmail';
  static const String homePage = '/home';
  static const String profilePage = '/profile';
  static const String settingsPage = '/settings';
  static const String notifications = '/notifications';
  static const String beneficiaries = '/beneficiaries';
  static const String history = '/history';
  static const String sendMoney = '/sendMoney';
  static const String receiveMoney = '/receiveMoney';
  static const String taux = '/taxes';


  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      
      case getStarted:
        return MaterialPageRoute(
          builder: (_) => const GetStarted(),
          settings: settings,
        );
        //return _errorRoute();
      
      case signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
          settings: settings,
        );
        //return _errorRoute();
      
      case signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
       );
        //return _errorRoute();
      
      case forgotPassword:
      // return MaterialPageRoute(
        //   builder: (_) => const ForgotPasswordScreen(),
        //   settings: settings,
        // );
        return _errorRoute();
      
      case resetPassword: 
        // return MaterialPageRoute(
        //   builder: (_) => const ResetPasswordScreen(),
        //   settings: settings,
        // );
        return _errorRoute();
      
      case verifyEmail:
       return MaterialPageRoute(
           builder: (_) => const OTPPage(),
           settings: settings,
         );
        //return _errorRoute();
        
      case homePage:
        return MaterialPageRoute(
           builder: (_) => const HomePage(),
           settings: settings,
         );
        //return _errorRoute();
      
      case profilePage:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
        //return _errorRoute();
      
      case settingsPage:
         return MaterialPageRoute(
           builder: (_) => const SettingsPages(),
           settings: settings,
         );
      //return _errorRoute();

      case notifications:
         return MaterialPageRoute(
           builder: (_) => const NotificationsPage(),
           settings: settings,
         );
        //return _errorRoute();
      
      case beneficiaries:
         return MaterialPageRoute(
           builder: (_) => const BeneficiariesPage(),
           settings: settings,
         );
        //return _errorRoute();
      
      case history:
         return MaterialPageRoute(
           builder: (_) => const TransactionHistoryPage(),
           settings: settings,
         );
        //return _errorRoute();
      
      case sendMoney:
      // return MaterialPageRoute(
        //   builder: (_) => const SendMoneyPage(),
        //   settings: settings,
        // );
        return _errorRoute();
      
      case receiveMoney:
      // return MaterialPageRoute(
        //   builder: (_) => const ReceiveMoneyPage(),
        //   settings: settings,
        // );
        return _errorRoute();
      
      case taux:
       return MaterialPageRoute(
           builder: (_) =>  ExchangePage(),
           settings: settings,
         );
        //return _errorRoute();
      
      
      default:
        return _errorRoute();
    }
  }

  // Page d'erreur pour les routes non trouvées
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: const Center(
          child: Text('Page non trouvée'),
        ),
      ),
    );
  }

  // Méthodes de navigation utilitaires
  static void goToLanding(BuildContext context) {
    Navigator.pushReplacementNamed(context, getStarted);
  }

  static void goTosignIn(BuildContext context) {
    Navigator.pushReplacementNamed(context, signIn);
  }

  static void goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, homePage);
  }
  static void goToSignUp(BuildContext context) {
    Navigator.pushReplacementNamed(context, signUp);
  }
  static void goToForgotPassword(BuildContext context) {
    Navigator.pushReplacementNamed(context, forgotPassword);
  }
  static void goToResetPassword(BuildContext context) {
    Navigator.pushReplacementNamed(context, resetPassword);
  }
  static void goToVerifyEmail(BuildContext context) {
    Navigator.pushReplacementNamed(context, verifyEmail);
  }

  static void goToProfilePage(BuildContext context) {
    Navigator.pushNamed(context, profilePage);
  }
  static void goToSettingsPage(BuildContext context) {
    Navigator.pushNamed(context, settingsPage);
  }
  static void goToNotificationsPage(BuildContext context) {
    Navigator.pushNamed(context, notifications);
  }
  static void goToBeneficiariesPage(BuildContext context) {
    Navigator.pushNamed(context, beneficiaries);
  }
  static void goToHistoryPage(BuildContext context) {
    Navigator.pushNamed(context, history);
  }
  static void goToSendMoneyPage(BuildContext context) {
    Navigator.pushNamed(context, sendMoney);
  }
  static void goToReceiveMoneyPage(BuildContext context) {
    Navigator.pushNamed(context, receiveMoney);
  }
  static void goToTaxesPage(BuildContext context) {
    Navigator.pushNamed(context, taux);
  }
}