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
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Obx(() {
                  // Center content vertically
                  return IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // 👈 added padding
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
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
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
                                        _buildDetailRow(
                                            'Branch', controller.expertBranch.value),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Description
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, bottom: 4),
                                  child: Text(
                                    'Description',
                                    style: AppFonts.bodyText1Style.copyWith(
                                      fontWeight: AppFonts.semiBold,
                                      color: AppColors.primary,
                                      fontSize: 14,
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
                                    hintStyle: const TextStyle(fontSize: 14),
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
                                const SizedBox(height: 12),

                                // Attachments
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, bottom: 4),
                                  child: Text(
                                    'Attachments',
                                    style: AppFonts.bodyText1Style.copyWith(
                                      fontWeight: AppFonts.semiBold,
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: controller.pickAttachment,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
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
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(() => ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : controller.submitComplaint,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
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
                                                  fontSize: 14,
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
}
