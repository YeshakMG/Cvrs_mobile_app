import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/myid_controller.dart';

class MyidView extends GetView<MyidController> {
  const MyidView({super.key});

  @override
  Widget build(BuildContext context) {
    // Adjustable top padding for the whole card section
    const double topPadding = 80.0;
    // Dashed border settings
    const double dashLength = 50.0;
    const double gapLength = 100;
    const double borderWidth = 4.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My ID',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offNamed('/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: topPadding),
            const Text(
              'Front Side',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.secondary,
                
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Center(
              child: DashedBorderCard(
                width: 320,
                height: 200,
                dashLength: dashLength,
                gapLength: gapLength,
                borderWidth: borderWidth,
                child: Image.asset('assets/images/myid_fronnt.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Back Side',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Center(
              child: DashedBorderCard(
                width: 320,
                height: 200,
                dashLength: dashLength,
                gapLength: gapLength,
                borderWidth: borderWidth,
                child: Image.asset('assets/images/myid_back.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}

class DashedBorderCard extends StatelessWidget {
  final double width;
  final double height;
  final double dashLength;
  final double gapLength;
  final double borderWidth;
  final Widget child;

  const DashedBorderCard({
    super.key,
    required this.width,
    required this.height,
    required this.dashLength,
    required this.gapLength,
    required this.borderWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: AppColors.primary,
        width: borderWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: child,
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.width,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // Draw dashed border for all four sides
    _drawDashedLine(canvas, paint, Offset(0, 0), Offset(size.width, 0)); // top
    _drawDashedLine(canvas, paint, Offset(size.width, 0), Offset(size.width, size.height)); // right
    _drawDashedLine(canvas, paint, Offset(size.width, size.height), Offset(0, size.height)); // bottom
    _drawDashedLine(canvas, paint, Offset(0, size.height), Offset(0, 0)); // left
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;
    double drawn = 0.0;

    while (drawn < totalDistance) {
      final currentDashLength = (drawn + dashLength > totalDistance) ? totalDistance - drawn : dashLength;
      canvas.drawLine(start + direction * drawn, start + direction * (drawn + currentDashLength), paint);
      drawn += currentDashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
