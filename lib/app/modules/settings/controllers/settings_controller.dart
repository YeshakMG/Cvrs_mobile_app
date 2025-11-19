import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  //TODO: Implement SettingsController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void navigateToAboutUs() {
    // TODO: Implement navigation to About Us page
    Get.snackbar('About Us', 'Navigate to About Us page');
  }

  void navigateToPrivacyPolicies() {
    // TODO: Implement navigation to Privacy Policies page
    Get.snackbar('Privacy Policies', 'Navigate to Privacy Policies page');
  }

  void navigateToTermsAndConditions() {
    // TODO: Implement navigation to Terms and Conditions page
    Get.snackbar('Terms and Conditions', 'Navigate to Terms and Conditions page');
  }

  void navigateToContactUs() {
    // TODO: Implement navigation to Contact Us page
    Get.snackbar('Contact Us', 'Navigate to Contact Us page');
  }

  void logout() {
    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textCancel: 'Cancel',
      textConfirm: 'Yes',
      confirmTextColor: Colors.white,
      onCancel: () {},
      onConfirm: () {
        // Navigate to login page
        Get.offAllNamed('/login');
      },
    );
  }
}
