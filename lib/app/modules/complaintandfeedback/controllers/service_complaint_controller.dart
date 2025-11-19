import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ServiceComplaintController extends GetxController {
  // Service Types from resident id and vital services
  final List<String> serviceTypes = [
    'Resident ID',
    'Birth Certificate', 
    'Death Certificate',
    'Adoption  Certificate',
    'Marriage Certificate',
    'Family resgistration',
    'Resident Transfer'


  ];

  // Branches
  final List<String> branches = [
    'Central',
    'Sub-cities',
    'Mesob',
  ];

  // Sub-branches based on main branch
  final Map<String, List<String>> subBranches = {
    'Central': ['Addisu Gebeya', 'Megenagna', 'Lafto',],
    'Sub-cities': [
      'Addis Ketema',
      'Akaki Kaliti',
      'Arada',
      'Bole',
      'Gullele',
      'Kirkos',
      'Kolfe Keranio',
      'Lideta',
      'Nifas Silk-Lafto',
      'Yeka',
      'Lemi Kura'
    ],
    'Mesob': ['Mesob Central', 'Mesob 2', 'Mesob 3'],
  };

  // Selected values
  final selectedServiceType = ''.obs;
  final selectedBranch = ''.obs; // Start with empty to hide sub-branches initially
  final selectedSubBranch = ''.obs;

  // Text controller for description
  final TextEditingController descriptionController = TextEditingController();

  // Attachment
  final selectedFileName = ''.obs;
  File? selectedFile;

  @override
  void onInit() {
    super.onInit();
    // Initialize sub-branch based on selected branch
    updateSubBranchOptions();
  }

  void updateSubBranchOptions() {
    final subBranchList = subBranches[selectedBranch.value] ?? [];
    if (subBranchList.isNotEmpty) {
      selectedSubBranch.value = subBranchList[0];
    } else {
      selectedSubBranch.value = '';
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void pickAttachment() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedFile = File(pickedFile.path);
        selectedFileName.value = pickedFile.name;

        // Check file size (10MB limit)
        final fileSize = await selectedFile!.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB in bytes
          Get.snackbar(
            'Error',
            'File size must be less than 10MB',
            snackPosition: SnackPosition.BOTTOM,
          );
          selectedFile = null;
          selectedFileName.value = '';
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void submitComplaint() {
    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Submit complaint to backend
    Get.snackbar(
      'Success',
      'Complaint submitted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate back or to success page
    Get.back();
  }
}