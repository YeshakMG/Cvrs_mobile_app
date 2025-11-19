import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../views/expert_complaint_scan_view.dart';

class ExpertComplaintController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final ImagePicker picker = ImagePicker();

  // Expert Details
  var expertName = ''.obs;
  var expertPosition = ''.obs;
  var expertDepartment = ''.obs;
  var expertBranch = ''.obs;

  // Form Fields
  final descriptionController = TextEditingController();
  var selectedFileName = ''.obs;
  var selectedFile = Rx<File?>(null);

  // Loading and States
  var isScanning = false.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    scannerController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Scan QR Code
  void startScanning() {
    isScanning.value = true;
    Get.to(() => const ExpertComplaintScanView());
  }

  // Handle Scanned QR Code
  void onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        parseBadgeData(barcode.rawValue!);
        Get.back(); // Close scanner
        break;
      }
    }
  }

  // Upload Badge Image
  Future<void> uploadBadge() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedFile.value = File(image.path);
        selectedFileName.value = image.name;
        // TODO: Parse image for QR code or expert details
        parseBadgeData('Sample Expert Data'); // Placeholder
        Get.snackbar('Success', 'Badge uploaded successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }


  // Parse Badge Data (Placeholder - assume JSON or specific format)
  void parseBadgeData(String data) {
    // Placeholder parsing logic
    // Assume data is JSON like: {"name":"John Doe","position":"Manager","department":"IT","branch":"Main"}
    try {
      // For demo, hardcode or parse
      expertName.value = 'Isaac Mesfin';
      expertPosition.value = 'Team Leader';
      expertDepartment.value = 'Document verfication';
      expertBranch.value = 'Addisu Gebeya';
    } catch (e) {
      Get.snackbar('Error', 'Invalid badge data');
    }
  }

  // Pick Attachment
  Future<void> pickAttachment() async {
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        selectedFile.value = File(file.path);
        selectedFileName.value = file.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  // Submit Complaint
  void submitComplaint() {
    if (expertName.isEmpty) {
      Get.snackbar('Error', 'Please scan or upload expert badge first');
      return;
    }
    if (descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a description');
      return;
    }

    isLoading.value = true;
    // TODO: Implement submission logic
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar('Success', 'Expert complaint submitted successfully');
      Get.back();
    });
  }
}