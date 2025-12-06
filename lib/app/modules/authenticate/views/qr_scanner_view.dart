import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: [BarcodeFormat.qrCode],
    autoStart: true,
  );
  bool isScanning = false;
  bool isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Offset>? detectedCorners;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is required to scan QR codes',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
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

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      print('Barcode detected: rawValue = ${barcode.rawValue}, format = ${barcode.format}');
      if (barcode.corners != null && barcode.corners!.isNotEmpty) {
        setState(() {
          detectedCorners = barcode.corners;
        });
      }
      if (!isScanning && barcode.rawValue != null) {
        print('Valid barcode detected in frame');
        setState(() {
          isScanning = true;
        });

        // Simulate processing time with shimmer
        Future.delayed(const Duration(seconds: 1), () {
          print('Returning barcode result: ${barcode.rawValue}');
          Get.back(result: barcode.rawValue);
        });
        break; // Stop after first barcode detection
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive cutOutSize: 70% of screen width, but capped at reasonable sizes
    final cutOutSize = (screenWidth * 0.7).clamp(200.0, 350.0);
    final instructionPadding = screenWidth * 0.05; // 5% of screen width
    final instructionBottom = screenHeight * 0.1; // 10% from bottom

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'Scan QR Code',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            );
          },
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
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Scanner overlay with frame
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                borderColor: Colors.white,
                cutOutSize: cutOutSize,
              ),
            ),
          ),
          // Shimmering scan line
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ShimmeringLinePainter(
                    progress: _animation.value,
                    cutOutSize: cutOutSize,
                  ),
                );
              },
            ),
          ),
          // Dynamic frame around detected barcode
          if (detectedCorners != null)
            Positioned.fill(
              child: CustomPaint(
                painter: DetectedBarcodePainter(
                  corners: detectedCorners!,
                  borderColor: Colors.green,
                ),
              ),
            ),
          // Instructions
          Positioned(
            bottom: instructionBottom,
            left: instructionPadding,
            right: instructionPadding,
            child: Container(
              padding: EdgeInsets.all(instructionPadding),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final fontSize = isMobile ? 16.0 : 18.0;
                  return Text(
                    'Position the QR code within the frame to scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller?.dispose();
    super.dispose();
  }
}

class DetectedBarcodePainter extends CustomPainter {
  final List<Offset> corners;
  final Color borderColor;

  DetectedBarcodePainter({
    required this.corners,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.isEmpty) return;

    // Calculate bounding box
    double minX = corners.map((c) => c.dx).reduce((a, b) => a < b ? a : b);
    double maxX = corners.map((c) => c.dx).reduce((a, b) => a > b ? a : b);
    double minY = corners.map((c) => c.dy).reduce((a, b) => a < b ? a : b);
    double maxY = corners.map((c) => c.dy).reduce((a, b) => a > b ? a : b);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw bounding rectangle
    final rect = Rect.fromLTRB(minX, minY, maxX, maxY);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

class ShimmeringLinePainter extends CustomPainter {
  final double progress;
  final double cutOutSize;

  ShimmeringLinePainter({
    required this.progress,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfSize = cutOutSize / 2;

    // Calculate the Y position of the shimmering line
    final lineY = centerY - halfSize + (cutOutSize * progress);

    // Create gradient for shimmering effect
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.8),
        Colors.white,
        Colors.white.withOpacity(0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    );

    final linePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, lineY),
          width: cutOutSize,
          height: 4,
        ),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw the shimmering line
    canvas.drawLine(
      Offset(centerX - halfSize, lineY),
      Offset(centerX + halfSize, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}