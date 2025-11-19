import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants/colors.dart';
import '../controllers/expert_complaint_controller.dart';

class ExpertComplaintScanView extends StatefulWidget {
  const ExpertComplaintScanView({super.key});

  @override
  State<ExpertComplaintScanView> createState() => _ExpertComplaintScanViewState();
}

class _ExpertComplaintScanViewState extends State<ExpertComplaintScanView>
    with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  bool isScanning = false;
  bool isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void reassemble() {
    super.reassemble();
    controller.stop();
    controller.start();
  }

  Future<void> _toggleFlash() async {
    try {
      await controller.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Flash not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final expertController = Get.find<ExpertComplaintController>();
        expertController.selectedFile.value = File(pickedFile.path);
        expertController.selectedFileName.value = pickedFile.name;
        expertController.parseBadgeData('Sample Expert Data from Image');
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Scanning frame overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                borderColor: Colors.white,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          // Animated scanning line
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * 0.7) / 2 +
                     (_animation.value * MediaQuery.of(context).size.width * 0.7),
                left: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 2,
                  color: Colors.white.withOpacity(0.8),
                ),
              );
            },
          ),
          // Shimmer effect within the frame
          if (isScanning)
            Positioned(
              top: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * 0.7) / 2,
              left: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                child: Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Scanning...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Position the QR code within the frame to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (!isScanning && barcode.rawValue != null) {
        setState(() {
          isScanning = true;
        });

        // Simulate processing time with shimmer
        Future.delayed(const Duration(seconds: 1), () {
          final expertController = Get.find<ExpertComplaintController>();
          expertController.parseBadgeData(barcode.rawValue!);
          Get.back();
        });
        break; // Stop after first detection
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfSize = cutOutSize / 2;

    // Draw overlay rectangles around the scanning area (top, bottom, left, right)
    // Top rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, centerY - halfSize),
      paint,
    );
    // Bottom rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, centerY + halfSize, size.width, size.height - (centerY + halfSize)),
      paint,
    );
    // Left rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, centerY - halfSize, centerX - halfSize, cutOutSize),
      paint,
    );
    // Right rectangle
    canvas.drawRect(
      Rect.fromLTWH(centerX + halfSize, centerY - halfSize, size.width - (centerX + halfSize), cutOutSize),
      paint,
    );

    // Draw border
    final borderRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: cutOutSize,
      height: cutOutSize,
    );
    canvas.drawRect(borderRect, borderPaint);

    // Draw corner brackets
    final cornerLength = 30.0;
    final cornerWidth = 4.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth;

    // Top-left corner
    canvas.drawLine(
      Offset(centerX - cutOutSize / 2, centerY - cutOutSize / 2),
      Offset(centerX - cutOutSize / 2 + cornerLength, centerY - cutOutSize / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cutOutSize / 2, centerY - cutOutSize / 2),
      Offset(centerX - cutOutSize / 2, centerY - cutOutSize / 2 + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(centerX + cutOutSize / 2, centerY - cutOutSize / 2),
      Offset(centerX + cutOutSize / 2 - cornerLength, centerY - cutOutSize / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cutOutSize / 2, centerY - cutOutSize / 2),
      Offset(centerX + cutOutSize / 2, centerY - cutOutSize / 2 + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(centerX - cutOutSize / 2, centerY + cutOutSize / 2),
      Offset(centerX - cutOutSize / 2 + cornerLength, centerY + cutOutSize / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cutOutSize / 2, centerY + cutOutSize / 2),
      Offset(centerX - cutOutSize / 2, centerY + cutOutSize / 2 - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(centerX + cutOutSize / 2, centerY + cutOutSize / 2),
      Offset(centerX + cutOutSize / 2 - cornerLength, centerY + cutOutSize / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cutOutSize / 2, centerY + cutOutSize / 2),
      Offset(centerX + cutOutSize / 2, centerY + cutOutSize / 2 - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}