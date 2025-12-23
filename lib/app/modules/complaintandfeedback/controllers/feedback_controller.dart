import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../../../../services/api_service.dart';
import '../views/expert_complaint_scan_view.dart';

class FeedbackController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final ImagePicker picker = ImagePicker();

  var expertName = ''.obs;
  var expertPosition = ''.obs;
  var expertDepartment = ''.obs;
  var expertBranch = ''.obs;
  var userId = ''.obs;

  var rating = 0.obs;
  var isAgreed = false.obs;
  var isLoading = false.obs;

  final feedbackController = TextEditingController();

  @override
  void onClose() {
    scannerController.dispose();
    feedbackController.dispose();
    super.onClose();
  }

  void startScanning() {
    isLoading.value = true;
    Get.to(() => ExpertComplaintScanView(onDetected: parseBadgeData));
  }

  Future<void> parseBadgeData(String data) async {
    try {
      // Assume data is the user ID from QR code
      String scannedUserId = data.trim();

      if (scannedUserId.isEmpty) {
        Get.snackbar('Error', 'Invalid QR code data');
        return;
      }

      userId.value = scannedUserId;

      // Fetch user details from API
      final fullUrl = '${ApiService.to.baseUrl}api/v1/portal-bff/users/$scannedUserId';
      print('Calling API: $fullUrl');
      final response = await ApiService.to.get('api/v1/portal-bff/users/$scannedUserId');

      print('User Details API Response: ${response.data}');

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          final userData = apiResponse['data'];

          // Extract name from translations
          final translations = userData['translations'];
          String firstName = '';
          String middleName = '';
          String lastName = '';
          if (translations != null && translations['en'] != null) {
            final en = translations['en'];
            firstName = en['firstName'] ?? '';
            middleName = en['middleName'] ?? '';
            lastName = en['lastName'] ?? '';
          }
          expertName.value = '$firstName $middleName $lastName'.trim();

          // Position from jobPosition or default
          final jobPosition = userData['jobPosition'];
          expertPosition.value = jobPosition != null ? jobPosition['name'] ?? 'Unknown' : 'Unknown';

          // Department and Branch from structure
          final structure = userData['structure'];
          if (structure != null && structure['localizedContent'] != null && structure['localizedContent']['en'] != null) {
            final en = structure['localizedContent']['en'];
            expertDepartment.value = en['name'] ?? 'Unknown';
            expertBranch.value = en['name'] ?? 'Unknown';
          } else {
            expertDepartment.value = 'Unknown';
            expertBranch.value = 'Unknown';
          }
        } else {
          Get.snackbar('Error', 'Invalid API response structure');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch user details');
      }
    } catch (e) {
      print('Parse Badge Error: $e');
      Get.snackbar('Error', 'Failed to parse badge data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onQRCodeDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        await parseBadgeData(barcode.rawValue!);
        Get.back(); // Close scanner
        break;
      }
    }
  }

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> submitFeedback() async {
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
    if (feedbackController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide feedback text.');
      return;
    }

    isLoading.value = true;

    try {
      final data = {
        'userRequestId': userId.value,
        'rating': rating.value,
        'feedback': feedbackController.text.trim(),
      };

      print('Feedback Payload: $data');

      final response = await ApiService.to.post('api/v1/complaint-service/feedbacks', data: data);

      print('Feedback Submit Response: ${response.data}');

      Get.defaultDialog(
        title: 'Success',
        middleText: 'Feedback submitted successfully',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close dialog
          resetForm();
          Get.back(); // Go back to previous screen
        },
      );

    } catch (e) {
      print('Feedback Submit Error: $e');
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
    userId.value = '';
    rating.value = 0;
    isAgreed.value = false;
    feedbackController.clear();
  }
}
