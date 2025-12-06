import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expert Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

            // Responsive dimensions
            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final scanButtonWidth = isMobile ? 250.0 : (isTablet ? 300.0 : 350.0);
            final scanButtonPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            final scanIconSize = isMobile ? 32.0 : (isTablet ? 36.0 : 40.0);
            final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
            final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
            final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            final starSize = isMobile ? 36.0 : (isTablet ? 40.0 : 44.0);
            final buttonPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Obx(() {
                  return IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        mainAxisAlignment: controller.expertName.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // If not scanned yet
                          if (controller.expertName.isEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Please scan expert badge to provide feedback.',
                                  style: AppFonts.bodyText1Style.copyWith(
                                    fontWeight: AppFonts.regular,
                                    color: AppColors.primary,
                                    fontSize: fontSize,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: spacing),
                                InkWell(
                                  onTap: controller.startScanning,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: scanButtonPadding, horizontal: scanButtonPadding * 1.875), // 30/16 = 1.875
                                    width: scanButtonWidth,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner,
                                          color: AppColors.primary,
                                          size: scanIconSize,
                                        ),
                                        SizedBox(width: spacing),
                                        Text(
                                          'Scan QR Code',
                                          style: AppFonts.bodyText2Style.copyWith(
                                            color: AppColors.primary,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            // After scanning, show feedback form
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Expert details
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(cardPadding),
                                    child: Obx(() {
                                      if (controller.isLoading.value && controller.expertName.isEmpty) {
                                        return _buildExpertDetailsShimmer(isMobile, isTablet);
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Expert Details',
                                            style: AppFonts.bodyText1Style.copyWith(
                                              fontWeight: AppFonts.semiBold,
                                              color: AppColors.primary,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                          SizedBox(height: spacing),
                                          _buildDetailRow(
                                              'Name', controller.expertName.value, isMobile, isTablet),
                                          _buildDetailRow('Position',
                                              controller.expertPosition.value, isMobile, isTablet),
                                          _buildDetailRow('Department',
                                              controller.expertDepartment.value, isMobile, isTablet),
                                          _buildDetailRow('Branch',
                                              controller.expertBranch.value, isMobile, isTablet),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                SizedBox(height: spacing * 1.25), // 20/16 = 1.25

                                // Rating section
                                Text(
                                  'Rate the Expert',
                                  style: AppFonts.bodyText1Style.copyWith(
                                    fontWeight: AppFonts.semiBold,
                                    color: AppColors.primary,
                                    fontSize: fontSize,
                                  ),
                                ),
                                SizedBox(height: spacing),
                                Obx(() => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(5, (index) {
                                        final isSelected =
                                            index < controller.rating.value;
                                        return GestureDetector(
                                          onTap: () =>
                                              controller.setRating(index + 1),
                                          child: Icon(
                                            isSelected
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: isSelected
                                                ? Colors.amber
                                                : Colors.grey,
                                            size: starSize,
                                          ),
                                        );
                                      }),
                                    )),
                                SizedBox(height: spacing * 2),

                                // Terms checkbox
                                Obx(() => Row(
                                      children: [
                                        Checkbox(
                                          value: controller.isAgreed.value,
                                          activeColor: AppColors.primary,
                                          onChanged: (value) => controller
                                              .isAgreed.value = value ?? false,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'I agree with the terms and conditions.',
                                            style:
                                                AppFonts.bodyText2Style.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                SizedBox(height: spacing * 2),

                                // Submit button
                                Obx(() {
                                  if (controller.isLoading.value) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: buttonHeight,
                                      child: Shimmer.fromColors(
                                        baseColor: AppColors.primary.withOpacity(0.3),
                                        highlightColor: AppColors.primary.withOpacity(0.7),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: controller.submitFeedback,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Submit Feedback',
                                        style: AppFonts.bodyText1Style.copyWith(
                                          color: Colors.white,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile, bool isTablet) {
    final labelWidth = isMobile ? 120.0 : (isTablet ? 140.0 : 160.0);
    final padding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final fontSize = isMobile ? null : (isTablet ? 14.0 : 16.0);

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style: AppFonts.bodyText2Style.copyWith(
                fontWeight: AppFonts.medium,
                color: AppColors.textPrimary,
                fontSize: fontSize,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyText2Style.copyWith(
                color: AppColors.primary,
                fontWeight: AppFonts.semiBold,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertDetailsShimmer(bool isMobile, bool isTablet) {
    final titleWidth = isMobile ? 120.0 : (isTablet ? 140.0 : 160.0);
    final titleHeight = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final spacing = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    final labelWidth = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final labelHeight = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final valueWidth = isMobile ? 120.0 : (isTablet ? 140.0 : 160.0);
    final valueHeight = labelHeight;
    final padding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: titleWidth,
            height: titleHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: spacing),

        // Detail rows shimmer
        for (int i = 0; i < 4; i++) ...[
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(
              children: [
                // Label shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: labelWidth,
                    height: labelHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 20 : 24),
                // Value shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: valueWidth,
                    height: valueHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
