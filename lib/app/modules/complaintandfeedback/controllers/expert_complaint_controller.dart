import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:open_file/open_file.dart';

import '../../../../services/api_service.dart';
import '../views/expert_complaint_scan_view.dart';

class ExpertComplaintController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final ImagePicker picker = ImagePicker();

  // Expert Details
  var expertName = ''.obs;
  var expertPosition = ''.obs;
  var expertDepartment = ''.obs;
  var expertBranch = ''.obs;
  var userId = ''.obs;

  // Form Fields
  final descriptionController = TextEditingController();

  // Badge (single)
  var selectedFileName = ''.obs;
  var selectedFile = Rx<File?>(null);

  // Attachments (multiple)
  final selectedFileNames = <String>[].obs;
  final selectedFiles = <File>[].obs;
  final attachmentIds = <String>[].obs;

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
    Get.to(() => ExpertComplaintScanView(onDetected: parseBadgeData));
  }

  // Handle Scanned QR Code
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

  // Upload Badge Image
  Future<void> uploadBadge() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // For badge, keep single
        // TODO: Parse image for QR code or expert details
        parseBadgeData('Sample Expert Data'); // Placeholder
        Get.snackbar('Success', 'Badge uploaded successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }


  // Parse Badge Data - extract ID and fetch user details
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
      final fullUrl = '${ApiService.to.baseUrl}citizen-app-service/portal-bff/users/$userId';
      print('Calling API: $fullUrl');
      final response = await ApiService.to.get('citizen-app-service/portal-bff/users/$userId');

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
    }
  }

  // Pick Attachment
  Future<void> pickAttachment() async {
    try {
      final pickedFiles = await picker.pickMultiImage();
      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final name = pickedFile.name;

        // Check file size (10MB limit)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB in bytes
          Get.snackbar(
            'Error',
            'File size must be less than 10MB: $name',
            snackPosition: SnackPosition.BOTTOM,
          );
          continue;
        }

        // Upload the file automatically
        final id = await uploadFile(file, name);
        if (id != null) {
          selectedFiles.add(file);
          selectedFileNames.add(name);
          attachmentIds.add(id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick files: $e');
    }
  }

  Future<String?> uploadFile(File file, String name) async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: name),
      });

      // Create a new Dio instance without interceptors to avoid FormData reuse issues
      final uploadDio = dio.Dio(dio.BaseOptions(
        baseUrl: 'https://crrsa-api.risertechservices.com/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Note: This endpoint appears to be public, so no authorization header added

      final response = await uploadDio.post('api/v1/storage/files/public', data: formData);

      print('Upload Response Body: ${response.data}');

      // Assuming response.data is a Map with 'id'
      if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
        return response.data['id'].toString();
      }
    } catch (e) {
      print('Upload Error: $e');
    }
    return null;
  }

  void removeAttachment(int index) {
    selectedFiles.removeAt(index);
    selectedFileNames.removeAt(index);
    attachmentIds.removeAt(index);
  }

  void viewAttachment(int index) {
    final file = selectedFiles[index];
    OpenFile.open(file.path);
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

    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Confirm Submission',
      middleText: 'Are you sure you want to send the complaint?',
      textConfirm: 'Yes',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () => _performSubmit(),
    );
  }

  Future<void> _performSubmit() async {
    isLoading.value = true;

    try {
      final data = {
        'type': 'EXPERT',
        'userId': userId.value,
        'description': descriptionController.text,
        'attachments': attachmentIds.isNotEmpty ? attachmentIds.map((id) => {
          'attachmentId': id,
          'description': 'Supporting document'
        }).toList() : [],
      };

      final response = await ApiService.to.post('citizen-app-service/complaint-service/complaints', data: data);

      print('Expert Complaint Submit Response: ${response.data}');

      Get.defaultDialog(
        title: 'Success',
        middleText: 'Expert complaint submitted successfully',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Go back to previous screen
        },
      );
    } catch (e) {
      print('Expert Submit Error: $e');
      Get.snackbar('Error', 'Failed to submit complaint');
    } finally {
      isLoading.value = false;
    }
  }
}