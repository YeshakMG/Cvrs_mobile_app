import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  
  MobileScannerController? scannerController;

  @override
  void onInit() {
    super.onInit();
    initializeScanner();
  }

  @override
  void onClose() {
    scannerController?.dispose();
    super.onClose();
  }

  Future<void> initializeScanner() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isDenied) {
        errorMessage.value = 'Camera permission is required to scan QR codes.';
        isLoading.value = false;
        return;
      }

      // Check if permission is granted
      if (cameraPermission.isPermanentlyDenied) {
        errorMessage.value = 'Camera permission is permanently denied. Please enable it in app settings.';
        isLoading.value = false;
        return;
      }

      // Initialize scanner
      scannerController = MobileScannerController();
      isLoading.value = false;

    } catch (e) {
      errorMessage.value = 'Failed to initialize camera: $e';
      isLoading.value = false;
    }
  }

  void onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _processQRCode(code);
      }
    }
  }

  void _processQRCode(String qrData) {
    try {
      // Parse the QR code data (assuming it's in a specific format)
      // For example: "Name:John Doe|Position:Manager|Department:IT|Branch:Main"
      final Map<String, String> expertData = _parseQRData(qrData);
      
      if (expertData.isNotEmpty) {
        // Navigate back with the expert data
        Get.back(result: expertData);
      } else {
        _showErrorSnackBar('Invalid QR code format');
      }
    } catch (e) {
      _showErrorSnackBar('Error parsing QR code: $e');
    }
  }

  Map<String, String> _parseQRData(String qrData) {
    final Map<String, String> data = {};
    
    try {
      // Split by | to get key-value pairs
      final List<String> pairs = qrData.split('|');
      
      for (final pair in pairs) {
        final List<String> keyValue = pair.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
    } catch (e) {
      print('Error parsing QR data: $e');
    }
    
    return data;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Scan Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void requestPermission() {
    openAppSettings();
  }

  void stopScanning() {
    scannerController?.stop();
  }
}