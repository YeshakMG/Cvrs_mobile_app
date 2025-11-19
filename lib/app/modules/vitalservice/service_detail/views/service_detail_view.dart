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
              padding: const EdgeInsets.all(12),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          controller.service?.icon ?? Icons.help_outline,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              ),
                            ),
                            const SizedBox(height: 4),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: controller.service != null ? controller.getStatusColor(controller.service.status) : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
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
                            const SizedBox(height: 2),
                            // Description (reduced to 1 line)
                            Text(
                              controller.service?.description ?? 'No description available',
                              style: AppFonts.captionStyle.copyWith(
                                color: Colors.grey[600],
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Status',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.regular,
                  color: AppColors.primary,
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
                                   color: isCompleted ? Colors.green : Colors.grey[300],
                                   border: Border.all(
                                     color: isCurrentStep ? AppColors.primary : Colors.transparent,
                                     width: 2,
                                   ),
                                 ),
                                 child: Center(
                                   child: isCompleted
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
                                   color: isCompleted ? Colors.green : Colors.grey[300],
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
                                     fontSize: 14,
                                   ),
                                 ),
                                 // Step Description - Only show if step is reached/completed
                                 if (isCompleted || isCurrentStep) ...[
                                   const SizedBox(height: 4),
                                   Text(
                                     description,
                                     style: AppFonts.captionStyle.copyWith(
                                       color: AppColors.secondary,
                                       fontSize: 12,
                                     ),
                                   ),
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
      ),
    );
  }
}