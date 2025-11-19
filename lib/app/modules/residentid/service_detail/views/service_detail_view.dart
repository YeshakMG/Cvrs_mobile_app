import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/fonts.dart';
import '../../controllers/residentid_controller.dart';
import '../controllers/service_detail_controller.dart';

class ServiceDetailView extends GetView<ServiceDetailController> {
  const ServiceDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application Status',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          controller.service?.icon ?? Icons.help_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                    ),
                                  ),
                                ),
                                // Status with color
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: controller.service != null ? controller.getStatusColor(controller.service.status) : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    controller.service != null ? controller.getStatusDisplayName(controller.service.status) : 'Unknown',
                                    style: AppFonts.captionStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: AppFonts.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Description
                            Text(
                              controller.service?.description ?? 'No description available',
                              style: AppFonts.captionStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Status',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.regular,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),

            // Vertical Stepper
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(controller.steps.length, (index) {
                  final step = controller.steps[index];
                  final description = index < controller.stepDescriptions.length ? controller.stepDescriptions[index] : 'Step ${index + 1}';
                  final isCompleted = controller.isStepCompleted(index);
                  final isCurrentStep = index == controller.getCurrentStep();
                  final isLastStep = index == controller.steps.length - 1;
                  final isRejected = controller.service?.status == RequestStatus.rejected;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Circle and Line
                        SizedBox(
                          width: 30,
                          child: Column(
                            children: [
                              // Step Circle
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isRejected && isCurrentStep) ? Colors.red : (isCompleted ? Colors.green : Colors.grey[300]),
                                  border: Border.all(
                                    color: (isRejected && isCurrentStep) ? Colors.red : (isCurrentStep ? AppColors.primary : Colors.transparent),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: (isRejected && isCurrentStep)
                                      ? const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                ),
                              ),
                              // Connecting Line (except for last step)
                              if (!isLastStep)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: (isRejected && isCurrentStep) ? Colors.red : (isCompleted ? Colors.green : Colors.grey[300]),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Step Description - Only show for completed or current steps
                              if (isCompleted || isCurrentStep)
                                Text(
                                  description,
                                  style: AppFonts.captionStyle.copyWith(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              
                              // Rejection Reason and Date - Only show for current step when rejected
                              if (isRejected && isCurrentStep && controller.service?.rejectionReason != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.red,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Rejection Reason:',
                                              style: AppFonts.captionStyle.copyWith(
                                                color: Colors.red,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${controller.service?.rejectionReason}',
                                        style: AppFonts.captionStyle.copyWith(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (controller.service?.rejectionDate != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.red,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rejected on: ${controller.service?.rejectionDate}',
                                              style: AppFonts.captionStyle.copyWith(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
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
      ),
    );
  }
}
