import 'dart:ui';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}