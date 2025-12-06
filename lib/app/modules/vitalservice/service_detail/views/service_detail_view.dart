import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/fonts.dart';
import '../controllers/service_detail_controller.dart';

class ServiceDetailView extends GetView<ServiceDetailController> {
  const ServiceDetailView({super.key});
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
              'Application Status',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

          // Responsive dimensions
          final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
          final iconSize = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
          final iconContainerSize = isMobile ? 40.0 : (isTablet ? 50.0 : 60.0);
          final stepCircleSize = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);
          final stepIconSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
          final stepLineHeight = isMobile ? 40.0 : (isTablet ? 45.0 : 50.0);
          final fontSize = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Card
                Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : padding),
                  child: Card(
                    margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              controller.service?.icon ?? Icons.help_outline,
                              size: iconSize,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service Type
                                Text(
                                  controller.service?.serviceType ?? 'Unknown Service',
                                  style: AppFonts.bodyText2Style.copyWith(
                                    fontWeight: AppFonts.semiBold,
                                    color: AppColors.primary,
                                    fontSize: isMobile ? null : (isTablet ? 16.0 : 18.0),
                                  ),
                                ),
                                SizedBox(height: isMobile ? 4 : 6),
                                // Application ID and Status in row
                                Row(
                                  children: [
                                    // Application ID
                                    Expanded(
                                      child: Text(
                                        'Application ID: ${controller.service?.applicationId ?? 'N/A'}',
                                        style: AppFonts.overlineStyle.copyWith(
                                          color: AppColors.secondary,
                                          fontWeight: AppFonts.bold,
                                          fontSize: isMobile ? null : (isTablet ? 13.0 : 14.0),
                                        ),
                                      ),
                                    ),
                                    // Status with color
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 6 : 8,
                                        vertical: isMobile ? 1 : 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: controller.service != null ? controller.getStatusColor(controller.service.status) : Colors.grey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        controller.service != null ? controller.getStatusDisplayName(controller.service.status) : 'Unknown',
                                        style: AppFonts.captionStyle.copyWith(
                                          color: Colors.white,
                                          fontWeight: AppFonts.bold,
                                          fontSize: isMobile ? null : (isTablet ? 12.0 : 13.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 2 : 4),
                                // Description (reduced to 1 line)
                                Text(
                                  controller.service?.description ?? 'No description available',
                                  style: AppFonts.captionStyle.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? null : (isTablet ? 13.0 : 14.0),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Application Status Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    'Status',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.regular,
                      color: AppColors.primary,
                      fontSize: fontSize,
                    ),
                  ),
                ),

                // Vertical Stepper
                Container(
                  margin: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(controller.steps.length, (index) {
                      final step = controller.steps[index];
                      final description = index < controller.stepDescriptions.length ? controller.stepDescriptions[index] : 'Step ${index + 1}';
                      final isCompleted = controller.isStepCompleted(index);
                      final isCurrentStep = index == controller.getCurrentStep();
                      final isLastStep = index == controller.steps.length - 1;

                      return Container(
                        margin: EdgeInsets.only(bottom: isMobile ? 20 : 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step Circle and Line
                            SizedBox(
                              width: stepCircleSize,
                              child: Column(
                                children: [
                                  // Step Circle
                                  Container(
                                    width: stepCircleSize,
                                    height: stepCircleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted ? Colors.green : Colors.grey[300],
                                      border: Border.all(
                                        color: isCurrentStep ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: isCompleted
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: stepIconSize,
                                            )
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMobile ? 12 : 14,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Connecting Line (except for last step)
                                  if (!isLastStep)
                                    Container(
                                      width: 2,
                                      height: stepLineHeight,
                                      color: isCompleted ? Colors.green : Colors.grey[300],
                                      margin: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: isMobile ? 12 : 16),
                            // Step Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step Title
                                  Text(
                                    step,
                                    style: AppFonts.captionStyle.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: AppFonts.semiBold,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  // Step Description - Only show if step is reached/completed
                                  if (isCompleted || isCurrentStep) ...[
                                    SizedBox(height: isMobile ? 4 : 6),
                                    Obx(() => Text(
                                      controller.stepDescriptions[index],
                                      style: AppFonts.captionStyle.copyWith(
                                        color: AppColors.secondary,
                                        fontSize: fontSize,
                                      ),
                                    )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}