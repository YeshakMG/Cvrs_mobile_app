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
        title: const Text(
          'Complaint & Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Description Text
              const Text(
                'Share your complaints or feedback about the services received and the experts who assisted you. Your input helps us improve our service quality and accountability.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),

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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        // Feedback Card
                        _buildOptionCard(
                          context,
                          'Feedback',
                          Icons.feedback,
                          () => controller.selectOption('feedback'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 170,
        height: 114,
        padding: const EdgeInsets.all(20),
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
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppFonts.bodyText1Style.copyWith(
                fontWeight: AppFonts.semiBold,
                color: AppColors.primary,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
