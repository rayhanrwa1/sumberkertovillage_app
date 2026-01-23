import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeController extends GetxController {
  final currentPage = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skipOnboarding() {
    Get.offAllNamed('/register');
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
