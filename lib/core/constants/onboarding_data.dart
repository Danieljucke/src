import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_item.dart';

const List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: 'Easy To Use',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vestibulum maximus consequat. Sed lacinia fermentum nunc. Phasellus porta. Fusce suscipit varius mauris. Cum sociis natoque penatibus et magnis dis parturient',
    imagePath: 'assets/images/onboarding_1.png',
    backgroundColor: Color(0xFFE8F4FD),
  ),
  OnboardingItem(
    title: 'Secure & Fast',
    description: 'Your transactions are protected with bank-level security. Experience lightning-fast transfers across Africa with our optimized network.',
    imagePath: 'assets/images/onboarding_2.png',
    backgroundColor: Color(0xFFF0F8E8),
  ),
  OnboardingItem(
    title: 'Multi-Currency',
    description: 'Support for multiple African currencies. Send money across borders without worrying about exchange rates or hidden fees.',
    imagePath: 'assets/images/onboarding_3.png',
    backgroundColor: Color(0xFFFFF4E8),
  ),
];