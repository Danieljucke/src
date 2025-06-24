import 'package:flutter/material.dart';
import 'package:mobile/core/router/app_route.dart';
import 'package:mobile/presentation/widgets/banner/special_offer_banner.dart';
import 'package:mobile/presentation/widgets/cards/balance_card.dart';
import 'package:mobile/presentation/widgets/sections/stat_section.dart';
import 'package:mobile/presentation/widgets/sections/action_section.dart';
import 'package:mobile/presentation/widgets/navbar/navbar.dart';
import 'package:mobile/core/constants/app_constants.dart';  


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceVisible = true;
  int _currentIndex = 0;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        AppRouter.goToHome(context);
        break;
      case 1:
        AppRouter.goToBeneficiariesPage(context);
        break;
      case 2:
        AppRouter.goToHistoryPage(context);
        break;
      case 3:
        AppRouter.goToProfilePage(context);
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    BalanceCard(
                      username: 'Username',
                      balance: 2450.00,
                      currency: 'MAD',
                      isVisible: _isBalanceVisible,
                      onVisibilityToggle: _toggleBalanceVisibility,
                    ),
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    // Quick Actions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: QuickActionsSection(),
                    ),
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    // Special Offer Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: SpecialOfferBanner(),
                    ),
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    // Stats Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: StatsSection(
                        transfersThisMonth: 12,
                        totalSent: 5.2,
                        currency: 'MAD',
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}