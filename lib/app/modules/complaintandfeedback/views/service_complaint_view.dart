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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine device type
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

            // Responsive dimensions
            final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final verticalSpacing = isMobile ? 10.0 : (isTablet ? 12.0 : 16.0);
            final sectionSpacing = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
            final fieldPadding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
            final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
            final iconSize = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: verticalSpacing),

                  /// Service Type Dropdown
                  Text(
                    'Select Service Type',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.semiBold,
                      color: AppColors.primary,
                      fontSize: fontSize,
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(horizontal: fieldPadding),
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
                        hint: Text(
                          'Services',
                          style: TextStyle(fontSize: fontSize),
                        ),
                        items: controller.serviceTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: fontSize),
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

                  SizedBox(height: verticalSpacing),

                  /// Branch Dropdown
                  Text(
                    'Branch',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.semiBold,
                      color: AppColors.primary,
                      fontSize: fontSize,
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(horizontal: fieldPadding),
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
                        hint: Text(
                          'Select Branch',
                          style: TextStyle(fontSize: fontSize),
                        ),
                        items: controller.branches.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: fontSize),
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

                  SizedBox(height: verticalSpacing * 2),

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
                        fontSize: fontSize,
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    ...subBranchList.map(
                      (subBranch) => InkWell(
                        onTap: () {
                          controller.selectedSubBranch.value = subBranch;
                          controller.updateWoredaOptions();
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: sectionSpacing),
                          padding: EdgeInsets.all(fieldPadding),
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
                                size: iconSize,
                              ),
                              SizedBox(width: sectionSpacing),
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
                              ... (controller.selectedSubBranch.value ==
                                  subBranch ? [Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: iconSize,
                              )] : []),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                  ],
                );
              }),

              /// Woreda Section
              Obx(() {
                final woredaList =
                    controller.woredas[controller.selectedSubBranch.value] ??
                        [];
                if (woredaList.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Woreda',
                      style: AppFonts.bodyText1Style.copyWith(
                        fontWeight: AppFonts.semiBold,
                        color: AppColors.primary,
                        fontSize: fontSize,
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    ...woredaList.map(
                      (woreda) => InkWell(
                        onTap: () =>
                            controller.selectedWoreda.value = woreda,
                        child: Container(
                          margin: EdgeInsets.only(bottom: sectionSpacing),
                          padding: EdgeInsets.all(fieldPadding),
                          decoration: BoxDecoration(
                            color: controller.selectedWoreda.value == woreda
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color: controller.selectedWoreda.value == woreda
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: controller.selectedWoreda.value == woreda
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.6),
                                size: iconSize,
                              ),
                              SizedBox(width: sectionSpacing),
                              Expanded(
                                child: Text(
                                  woreda,
                                  style: AppFonts.bodyText2Style.copyWith(
                                    color: controller.selectedWoreda.value ==
                                            woreda
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: controller.selectedWoreda.value ==
                                            woreda
                                        ? AppFonts.medium
                                        : AppFonts.regular,
                                  ),
                                ),
                              ),
                              if (controller.selectedWoreda.value == woreda)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: iconSize,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                  ],
                );
              }),

              /// Description Field
              Text(
                'Description',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: fontSize,
                ),
              ),
              SizedBox(height: sectionSpacing),
              TextField(
                controller: controller.descriptionController,
                maxLength: 100,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your complaint here...',
                  hintStyle: TextStyle(fontSize: fontSize),
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

              SizedBox(height: sectionSpacing),

              /// Attachments
              Text(
                'Attachments',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                  fontSize: fontSize,
                ),
              ),
              SizedBox(height: sectionSpacing),
              InkWell(
                onTap: controller.pickAttachment,
                child: Container(
                  padding: EdgeInsets.all(fieldPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: AppColors.primary,
                        size: iconSize,
                      ),
                      SizedBox(width: sectionSpacing),
                      Expanded(
                        child: Obx(
                          () => Text(
                            controller.selectedFileName.value.isEmpty
                                ? 'Tap to attach file'
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

              SizedBox(height: verticalSpacing * 4),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: fieldPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit Complaint',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.regular,
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  ),
                ),
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
}
