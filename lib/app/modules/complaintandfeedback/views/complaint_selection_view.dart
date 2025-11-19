import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/complaint_selection_controller.dart';

class ComplaintSelectionView extends GetView<ComplaintSelectionController> {
  const ComplaintSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaint Type',
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
              const SizedBox(height: 32),

              // Short Description
              Text(
                'Select whether your concern relates to the service experience or the expert’s performance.',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.regular,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // Service and Expert Cards side by side
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      context,
                      'Service',
                      Icons.miscellaneous_services_rounded,
                      () => controller.selectComplaintType('service'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOptionCard(
                      context,
                      'Expert',
                      Icons.person_outline_rounded,
                      () => controller.selectComplaintType('expert'),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
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
