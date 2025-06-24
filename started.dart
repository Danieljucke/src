import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository_impl.dart';
import '../../core/router/app_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 2), () {
      // Vérification de la logique de connexion ici
      bool isConnected = AuthRepositoryImpl().isLoggedIn() as bool; 
      
      if (isConnected) {
        // Si l'utilisateur est connecté, redirigez vers la page "home"
        AppRouter.goToHome(context);
      } else {
        AppRouter.goToLanding(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 400),
                    // Logo de l'application
                    Transform.rotate(
                      angle: -35 * 3.1415926535 / 180, // 35 degrees in radians
                      child: Image.asset(
                      'assets/images/wallet_africa_logo.png',
                      width: 75,
                      height: 75,
                      ),
                    ),
                    const SizedBox(height: 35),
                    // Nom de l'application
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Wallet ',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3AAB67),
                            ),
                          ),
                          TextSpan(
                            text: 'Africa',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:FontWeight.w700 ,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Wallet Student',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:FontWeight.w700 ,
                              color: Color(0xffE0A200),
                            ),
                          ),
                        ],
                      ),
                    )          
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}