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
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'Complaint Type',
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

            // Responsive dimensions
            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final topSpacing = isMobile ? 32.0 : (isTablet ? 40.0 : 48.0);
            final descriptionFontSize = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
            final spacing = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
            final cardSpacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topSpacing),

                  // Short Description
                  Text(
                    'Select whether your concern relates to the service experience or the expert\'s performance.',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.regular,
                      color: AppColors.primary,
                      fontSize: descriptionFontSize,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Service and Expert Cards side by side
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          'Service',
                          Icons.miscellaneous_services_rounded,
                          () => controller.selectComplaintType('service'),
                          isMobile,
                          isTablet,
                        ),
                      ),
                      SizedBox(width: cardSpacing),
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          'Expert',
                          Icons.person_outline_rounded,
                          () => controller.selectComplaintType('expert'),
                          isMobile,
                          isTablet,
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
    bool isMobile,
    bool isTablet,
  ) {
    final cardWidth = isMobile ? 170.0 : (isTablet ? 200.0 : 230.0);
    final cardHeight = isMobile ? 114.0 : (isTablet ? 130.0 : 150.0);
    final padding = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final iconSize = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
    final spacing = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);

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
              size: iconSize,
            ),
            SizedBox(height: spacing),
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
