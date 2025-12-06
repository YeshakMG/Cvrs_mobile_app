import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/expert_complaint_controller.dart';

class ExpertComplaintView extends GetView<ExpertComplaintController> {
  const ExpertComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expert Complaint',
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
            final textFieldPadding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
            final attachmentPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            final buttonPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Obx(() {
                  // Center content vertically
                  return IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        mainAxisAlignment: controller.expertName.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.expertName.isEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Please scan expert badge or upload it from file for complaint submission',
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
                            // Show expert details and form
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(cardPadding),
                                    child: Column(
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
                                        _buildDetailRow(
                                            'Branch', controller.expertBranch.value, isMobile, isTablet),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing * 1.25), // 20/16 = 1.25

                                // Description
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: textFieldPadding, bottom: 4),
                                  child: Text(
                                    'Description',
                                    style: AppFonts.bodyText1Style.copyWith(
                                      fontWeight: AppFonts.semiBold,
                                      color: AppColors.primary,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: controller.descriptionController,
                                  maxLength: 100,
                                  maxLines: 4,
                                  cursorColor: AppColors.primary,
                                  cursorWidth: 2.0,
                                  cursorRadius: const Radius.circular(2),
                                  decoration: InputDecoration(
                                    hintText: 'Type your complaint here...',
                                    hintStyle: TextStyle(fontSize: fontSize),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    counterText:
                                        '${controller.descriptionController.text.length}/100',
                                  ),
                                ),
                                SizedBox(height: spacing),

                                // Attachments
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: textFieldPadding, bottom: 4),
                                  child: Text(
                                    'Attachments',
                                    style: AppFonts.bodyText1Style.copyWith(
                                      fontWeight: AppFonts.semiBold,
                                      color: AppColors.primary,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: controller.pickAttachment,
                                  child: Container(
                                    padding: EdgeInsets.all(attachmentPadding),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          color: AppColors.primary,
                                          size: isMobile ? 24.0 : (isTablet ? 26.0 : 28.0),
                                        ),
                                        SizedBox(width: spacing),
                                        Expanded(
                                          child: Obx(() => Text(
                                                controller.selectedFileName.value
                                                        .isEmpty
                                                    ? 'No file selected'
                                                    : controller
                                                        .selectedFileName.value,
                                                style:
                                                    AppFonts.bodyText2Style.copyWith(
                                                  color: controller
                                                          .selectedFileName
                                                          .value
                                                          .isEmpty
                                                      ? AppColors.textSecondary
                                                      : AppColors.primary,
                                                  fontSize: fontSize,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: spacing * 2),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(() => ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : controller.submitComplaint,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: EdgeInsets.symmetric(
                                              vertical: buttonPadding),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: controller.isLoading.value
                                            ? const CircularProgressIndicator(
                                                color: Colors.white)
                                            : Text(
                                                'Submit Complaint',
                                                style:
                                                    AppFonts.bodyText1Style.copyWith(
                                                  fontWeight: AppFonts.regular,
                                                  color: Colors.white,
                                                  fontSize: fontSize,
                                                ),
                                              ),
                                      )),
                                ),
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
}
