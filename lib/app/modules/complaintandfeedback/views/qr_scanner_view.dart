import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../controllers/qr_scanner_controller.dart';

class QRScannerView extends GetView<QRScannerController> {
  const QRScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Expert QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorView();
        }

        return _buildScannerView();
      }),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: AppFonts.bodyText1Style.copyWith(
                fontWeight: AppFonts.bold,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: AppFonts.bodyText2Style.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.requestPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Grant Permission',
                style: AppFonts.bodyText2Style.copyWith(
                  color: Colors.white,
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shimmering QR code icon
              Shimmer.fromColors(
                baseColor: AppColors.primary.withOpacity(0.3),
                highlightColor: AppColors.primary.withOpacity(0.7),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Shimmering loading text
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Shimmering progress indicator
              Shimmer.fromColors(
                baseColor: AppColors.primary.withOpacity(0.3),
                highlightColor: AppColors.primary.withOpacity(0.7),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        // Scanner Area
        MobileScanner(
          onDetect: controller.onQRCodeDetected,
        ),
        
        // Overlay
        _buildScannerOverlay(),
        
        // Instructions
        _buildInstructions(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                Positioned(
                  top: -1,
                  left: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.primary, width: 4),
                        top: BorderSide(color: AppColors.primary, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.primary, width: 4),
                        top: BorderSide(color: AppColors.primary, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  left: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.primary, width: 4),
                        bottom: BorderSide(color: AppColors.primary, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.primary, width: 4),
                        bottom: BorderSide(color: AppColors.primary, width: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Position the QR code within the frame',
            style: AppFonts.bodyText2Style.copyWith(
              color: Colors.white,
              fontWeight: AppFonts.medium,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}