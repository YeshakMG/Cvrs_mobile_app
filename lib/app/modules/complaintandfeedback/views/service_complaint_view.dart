import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/service_complaint_controller.dart';

class ServiceComplaintView extends GetView<ServiceComplaintController> {
  const ServiceComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Complaint',
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
              const SizedBox(height: 10),

              /// Service Type Dropdown
              Text(
                'Select Service Type',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedServiceType.value.isEmpty
                        ? null
                        : controller.selectedServiceType.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Services',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: controller.serviceTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedServiceType.value = newValue;
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Branch Dropdown
              Text(
                'Branch',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedBranch.value.isEmpty
                        ? null
                        : controller.selectedBranch.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Select Branch',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: controller.branches.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      controller.selectedBranch.value = newValue!;
                      controller.updateSubBranchOptions();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Sub-Branch Section
              Obx(() {
                final subBranchList =
                    controller.subBranches[controller.selectedBranch.value] ??
                        [];
                if (subBranchList.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Sub-Branch',
                      style: AppFonts.bodyText1Style.copyWith(
                        fontWeight: AppFonts.semiBold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...subBranchList.map(
                      (subBranch) => InkWell(
                        onTap: () =>
                            controller.selectedSubBranch.value = subBranch,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: controller.selectedSubBranch.value ==
                                    subBranch
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color: controller.selectedSubBranch.value ==
                                      subBranch
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: controller.selectedSubBranch.value ==
                                        subBranch
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.6),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  subBranch,
                                  style: AppFonts.bodyText2Style.copyWith(
                                    color:
                                        controller.selectedSubBranch.value ==
                                                subBranch
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                    fontWeight:
                                        controller.selectedSubBranch.value ==
                                                subBranch
                                            ? AppFonts.medium
                                            : AppFonts.regular,
                                  ),
                                ),
                              ),
                              if (controller.selectedSubBranch.value ==
                                  subBranch)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              const SizedBox(height: 2),

              /// Description Field
              Text(
                'Description',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.descriptionController,
                maxLength: 100,
                maxLines: 4,
                decoration: InputDecoration(
                                      hint: const Text(
                      'Type your complaint here...',
                      style: TextStyle(fontSize: 14),
                    ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  counterText:
                      '${controller.descriptionController.text.length}/100',
                ),
              ),

              const SizedBox(height: 4),

              /// Attachments
              Text(
                'Attachments',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
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
                        child: Obx(
                          () => Text(
                            controller.selectedFileName.value.isEmpty
                                ? ''
                                : controller.selectedFileName.value,
                            style: AppFonts.bodyText2Style.copyWith(
                              color:
                                  controller.selectedFileName.value.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit Complaint',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.regular,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
