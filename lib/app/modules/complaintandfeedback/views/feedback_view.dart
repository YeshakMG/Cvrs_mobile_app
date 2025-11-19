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
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Obx(() {
                  return IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: controller.startScanning,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 30),
                                    width: 250,
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
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Scan QR Code',
                                          style: AppFonts.bodyText2Style.copyWith(
                                            color: AppColors.primary,
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
                                    padding: const EdgeInsets.all(16),
                                    child: Obx(() {
                                      if (controller.isLoading.value && controller.expertName.isEmpty) {
                                        return _buildExpertDetailsShimmer();
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Expert Details',
                                            style: AppFonts.bodyText1Style.copyWith(
                                              fontWeight: AppFonts.semiBold,
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDetailRow(
                                              'Name', controller.expertName.value),
                                          _buildDetailRow('Position',
                                              controller.expertPosition.value),
                                          _buildDetailRow('Department',
                                              controller.expertDepartment.value),
                                          _buildDetailRow('Branch',
                                              controller.expertBranch.value),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Rating section
                                Text(
                                  'Rate the Expert',
                                  style: AppFonts.bodyText1Style.copyWith(
                                    fontWeight: AppFonts.semiBold,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                                            size: 36,
                                          ),
                                        );
                                      }),
                                    )),
                                const SizedBox(height: 24),

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
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                const SizedBox(height: 24),

                                // Submit button
                                Obx(() {
                                  if (controller.isLoading.value) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 48,
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
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Submit Feedback',
                                        style: AppFonts.bodyText1Style.copyWith(
                                          color: Colors.white,
                                          fontSize: 14,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppFonts.bodyText2Style.copyWith(
                fontWeight: AppFonts.medium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyText2Style.copyWith(
                color: AppColors.primary,
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Detail rows shimmer
        for (int i = 0; i < 4; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Label shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Value shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 14,
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
