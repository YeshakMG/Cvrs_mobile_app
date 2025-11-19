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
    if (email.value.isEmpty || password.value.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _authService.login(email.value, password.value);
      
      if (success) {
        // Login successful - navigate to home
        Get.offNamed('/home');
      } else {
        errorMessage.value = 'Invalid username or password';
      }
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
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