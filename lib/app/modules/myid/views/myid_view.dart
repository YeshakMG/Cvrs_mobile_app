import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/myid_controller.dart';

class MyidView extends GetView<MyidController> {
  const MyidView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'My ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
              ),
            );
          },
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offNamed('/home'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

          // Responsive dimensions
          final topPadding = constraints.maxHeight * (isMobile ? 0.1 : 0.08);
          final cardWidth = constraints.maxWidth * (isMobile ? 0.85 : isTablet ? 0.7 : 0.5);
          final cardHeight = cardWidth * 0.625; // Maintain aspect ratio
          final textFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
          final spacing = isMobile ? 10.0 : (isTablet ? 15.0 : 20.0);

          // Dashed border settings
          final dashLength = isMobile ? 50.0 : 60.0;
          final gapLength = isMobile ? 100.0 : 120.0;
          final borderWidth = isMobile ? 4.0 : 5.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.02),
              child: Column(
                children: [
                  SizedBox(height: topPadding),
                  Text(
                    'Front Side',
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.normal,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing),
                  Center(
                    child: DashedBorderCard(
                      width: cardWidth,
                      height: cardHeight,
                      dashLength: dashLength,
                      gapLength: gapLength,
                      borderWidth: borderWidth,
                      child: Image.asset('assets/images/myid_fronnt.png', fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Text(
                    'Back Side',
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.normal,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing),
                  Center(
                    child: DashedBorderCard(
                      width: cardWidth,
                      height: cardHeight,
                      dashLength: dashLength,
                      gapLength: gapLength,
                      borderWidth: borderWidth,
                      child: Image.asset('assets/images/myid_back.png', fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                ],
              ),
            ),
          );
        },
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
