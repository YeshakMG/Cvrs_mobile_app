import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../views/qr_scanner_view.dart' as qr_scanner;

class AuthenticatedUser {
  final String certificateNo;
  final String fullName;
  final String dateOfBirth;
  final String address;
  final String phoneNo;
  final String nationality;

  AuthenticatedUser({
    required this.certificateNo,
    required this.fullName,
    required this.dateOfBirth,
    required this.address,
    required this.phoneNo,
    required this.nationality,
  });
}

class AuthenticateController extends GetxController {
  final certificateId = ''.obs;
  final residentId = 'RES-123456'.obs;
  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final authenticatedUser = Rx<AuthenticatedUser?>(null);

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

  void scanQRCode() async {
    try {
      final result = await Get.to(() => const qr_scanner.QRScannerPage());
      if (result != null && result is String) {
        certificateId.value = result;
        // Automatically authenticate after scanning
        authenticateCertificate();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to scan QR code',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void authenticateCertificate() async {
    if (certificateId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a certificate ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate authentication process
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, authenticate if certificate ID is not empty
    isAuthenticated.value = true;

    // Create dummy authenticated user data
    authenticatedUser.value = AuthenticatedUser(
      certificateNo: certificateId.value,
      fullName: 'Isaac Mesfin',
      dateOfBirth: '1990-01-15',
      address: 'Addis Ababa, Ethiopia',
      phoneNo: '+251 912 345 678',
      nationality: 'Ethiopian',
    );

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Certificate authenticated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
