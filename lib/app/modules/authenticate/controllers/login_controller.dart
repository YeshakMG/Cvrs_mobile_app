import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../../services/auth_service.dart';

class LoginController extends GetxController {
  // Form fields
  final email = ''.obs;
  final password = ''.obs;
  final rememberMe = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final obscurePassword = true.obs;

  // Auth service
  final AuthService _authService = Get.find<AuthService>();

  void updateEmail(String value) {
    email.value = value;
  }

  void updatePassword(String value) {
    password.value = value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    // Navigate to webview for authentication
    Get.toNamed(Routes.WEBVIEW);
  }

  void loginAsGuest() {
    // Set guest mode - navigate to home without authentication
    Get.offNamed('/home');
  }

  void forgotPassword() {
    // TODO: Implement forgot password functionality
    Get.snackbar(
      'Forgot Password',
      'Please contact support to reset your password',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onReady() {
    super.onReady();
    // Check if user is already authenticated
    if (_authService.isAuthenticated) {
      Get.offNamed('/home');
    }
  }
}