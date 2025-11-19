import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FeedbackController extends GetxController {
  var expertName = ''.obs;
  var expertPosition = ''.obs;
  var expertDepartment = ''.obs;
  var expertBranch = ''.obs;

  var rating = 0.obs;
  var isAgreed = false.obs;
  var isLoading = false.obs;

  void startScanning() async {
    // Navigate to QR scanner and wait for result
    final result = await Get.toNamed('/complaintandfeedback/qr-scanner');
    
    if (result != null && result is Map<String, String>) {
      // Parse the QR code data and populate expert details
      expertName.value = result['Name'] ?? '';
      expertPosition.value = result['Position'] ?? '';
      expertDepartment.value = result['Department'] ?? '';
      expertBranch.value = result['Branch'] ?? '';
      
      // Show success message
      Get.snackbar(
        'Success',
        'Expert details loaded from QR code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Show error if scanning was cancelled or failed
      Get.snackbar(
        'Error',
        'Failed to scan QR code or scan was cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void setRating(int value) {
    rating.value = value;
  }

  void submitFeedback() async {
    if (rating.value == 0) {
      Get.snackbar('Error', 'Please rate the expert before submitting.');
      return;
    }
    if (!isAgreed.value) {
      Get.snackbar('Error', 'You must agree to the terms.');
      return;
    }
    if (expertName.value.isEmpty) {
      Get.snackbar('Error', 'Please scan expert QR code first.');
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Here you would typically send the feedback to your backend
      print('Feedback submitted:');
      print('Expert Name: ${expertName.value}');
      print('Expert Position: ${expertPosition.value}');
      print('Expert Department: ${expertDepartment.value}');
      print('Expert Branch: ${expertBranch.value}');
      print('Rating: ${rating.value}');
      print('Agreed to terms: ${isAgreed.value}');

      Get.snackbar('Success', 'Feedback submitted successfully.');
      
      // Clear the form
      resetForm();

    } catch (e) {
      Get.snackbar('Error', 'Failed to submit feedback. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    expertName.value = '';
    expertPosition.value = '';
    expertDepartment.value = '';
    expertBranch.value = '';
    rating.value = 0;
    isAgreed.value = false;
  }
}
