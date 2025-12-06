import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ServiceComplaintController extends GetxController {
  // Service Types from resident id and vital services
  final List<String> serviceTypes = [
    'Resident ID',
    'Birth Certificate', 
  
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

  // Woredas based on sub-branch
  final Map<String, List<String>> woredas = {
    'Addis Ketema': ['Woreda 1', 'Woreda 2', 'Woreda 3'],
    'Akaki Kaliti': ['Woreda 1', 'Woreda 2'],
    'Arada': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4'],
    'Bole': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4', 'Woreda 5'],
    'Gullele': ['Woreda 1', 'Woreda 2', 'Woreda 3'],
    'Kirkos': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4'],
    'Kolfe Keranio': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4'],
    'Lideta': ['Woreda 1', 'Woreda 2', 'Woreda 3'],
    'Nifas Silk-Lafto': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4'],
    'Yeka': ['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4', 'Woreda 5'],
    'Lemi Kura': ['Woreda 1', 'Woreda 2'],
    // Add for other branches if needed
  };

  // Selected values
  final selectedServiceType = ''.obs;
  final selectedBranch = ''.obs; // Start with empty to hide sub-branches initially
  final selectedSubBranch = ''.obs;
  final selectedWoreda = ''.obs;

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
      updateWoredaOptions();
    } else {
      selectedSubBranch.value = '';
      selectedWoreda.value = '';
    }
  }

  void updateWoredaOptions() {
    final woredaList = woredas[selectedSubBranch.value] ?? [];
    if (woredaList.isNotEmpty) {
      selectedWoreda.value = woredaList[0];
    } else {
      selectedWoreda.value = '';
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
    // Validation
    List<String> errors = [];

    if (selectedServiceType.value.isEmpty) {
      errors.add('Please select a service type');
    }

    if (selectedBranch.value.isEmpty) {
      errors.add('Please select a branch');
    }

    if (selectedSubBranch.value.isEmpty) {
      errors.add('Please select a sub-branch');
    }

    if (selectedBranch.value == 'Sub-cities' && selectedWoreda.value.isEmpty) {
      errors.add('Please select a woreda');
    }

    if (descriptionController.text.trim().isEmpty) {
      errors.add('Please enter a description');
    }

    if (errors.isNotEmpty) {
      Get.snackbar(
        'Validation Error',
        errors.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    // TODO: Submit complaint to backend
    Get.snackbar(
      'Success',
      'Complaint submitted successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Reset form
    selectedServiceType.value = '';
    selectedBranch.value = '';
    selectedSubBranch.value = '';
    selectedWoreda.value = '';
    descriptionController.clear();
    selectedFileName.value = '';
    selectedFile = null;

    // Navigate back or to success page
    Get.back();
  }
}