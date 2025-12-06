import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/complaintandfeedback_controller.dart';

class ComplaintandfeedbackView extends GetView<ComplaintandfeedbackController> {
  const ComplaintandfeedbackView({super.key});
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
              'Complaint & Feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            );
          },
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final descriptionFontSize = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
            final spacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.05),

                  // Description Text
                  Text(
                    'Share your complaints or feedback about the services received and the experts who assisted you. Your input helps us improve our service quality and accountability.',
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: spacing),

                  // Complaint and Feedback Cards side by side
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Complaint Card
                            _buildOptionCard(
                              context,
                              'Complaint',
                              HugeIcons.strokeRoundedComplaint,
                              () => controller.selectOption('complaint'),
                              constraints,
                              isMobile,
                              isTablet,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Column(
                          children: [
                            // Feedback Card
                            _buildOptionCard(
                              context,
                              'Feedback',
                              Icons.feedback,
                              () => controller.selectOption('feedback'),
                              constraints,
                              isMobile,
                              isTablet,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    BoxConstraints constraints,
    bool isMobile,
    bool isTablet,
  ) {
    final cardWidth = (constraints.maxWidth - (isMobile ? 32 : (isTablet ? 48 : 64))) / 2;
    final cardHeight = cardWidth * 0.67; // Maintain aspect ratio
    final iconSize = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
    final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final padding = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: iconSize,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              title,
              style: AppFonts.bodyText1Style.copyWith(
                fontWeight: AppFonts.semiBold,
                color: AppColors.primary,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
