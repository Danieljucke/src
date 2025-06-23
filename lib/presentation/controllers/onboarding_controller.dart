import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile/core/constants/onboarding_data.dart';
import 'package:mobile/core/router/app_route.dart';

class OnboardingController extends ChangeNotifier {
  int _currentIndex = 0;
  bool _hasCompletedFullCycle = false;
  PageController? _pageController;
  Timer? _autoScrollTimer;
  final Set<int> _visitedPages = <int>{};
  bool _isDisposed = false; // Ajout d'un flag pour vérifier si le controller est disposé

  int get currentIndex => _currentIndex;
  bool get hasCompletedFullCycle => _hasCompletedFullCycle;
  bool get isButtonEnabled => _hasCompletedFullCycle;

  void setPageController(PageController controller) {
    _pageController = controller;
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Vérifier si le controller n'est pas disposé et si le PageController existe toujours
      if (_isDisposed || _pageController == null || !_pageController!.hasClients) {
        timer.cancel();
        return;
      }
      
      if (!_hasCompletedFullCycle) {
        final nextIndex = (_currentIndex + 1) % onboardingItems.length;
        _pageController!.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
    });
  }

  void onPageChanged(int index) {
    if (_isDisposed) return; // Éviter les modifications après dispose
    
    _currentIndex = index;
    _visitedPages.add(index);
    
    // Vérifie si toutes les pages ont été visitées
    if (_visitedPages.length >= onboardingItems.length) {
      _hasCompletedFullCycle = true;
      _autoScrollTimer?.cancel();
    }
    
    notifyListeners();
  }

  void onGetStartedPressed(BuildContext context) {
    if (_hasCompletedFullCycle) {
      AppRouter.goTosignIn(context);
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _autoScrollTimer?.cancel();
    _pageController = null;
    super.dispose();
  }
}
