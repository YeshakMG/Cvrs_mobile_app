import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // Validate input fields
    if (email.value.trim().isEmpty && password.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your username and password';
      return;
    } else if (email.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your username';
      return;
    } else if (password.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _authService.login(email.value.trim(), password.value.trim());

      if (success) {
        // Login successful - navigate to home
        print('Login successful');
        Get.offNamed('/home');
      } else {
        // Provide user-friendly error messages based on auth service response
        final authError = _authService.errorMessage.value.toLowerCase();
        if (authError.contains('invalid') || authError.contains('unauthorized') || authError.contains('401')) {
          errorMessage.value = 'Invalid username or password. Please check your credentials and try again.';
        } else if (authError.contains('network') || authError.contains('connection')) {
          errorMessage.value = 'Network connection error. Please check your internet connection and try again.';
        } else if (authError.contains('timeout')) {
          errorMessage.value = 'Connection timeout. Please try again.';
        } else {
          errorMessage.value = 'Unable to sign in. Please try again later.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please check your connection and try again.';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
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
  void onInit() {
    super.onInit();
    // Check if user is already authenticated
    if (_authService.isAuthenticated) {
      Get.offNamed('/home');
    }
  }
}