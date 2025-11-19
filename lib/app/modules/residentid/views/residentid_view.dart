import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../controllers/residentid_controller.dart';

class ResidentidView extends GetView<ResidentidController> {
  const ResidentidView({super.key});

  Widget _buildStatusTab(RequestStatus status) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      return GestureDetector(
        onTap: () => controller.selectStatus(status),
        child: Container(
          key: ValueKey(status),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              controller.getStatusDisplayName(status),
              style: AppFonts.captionStyle.copyWith(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? AppFonts.semiBold : AppFonts.regular,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildServiceCard(ResidentService service) {
    return Semantics(
      label: 'Service card for ${service.serviceType}',
      child: GestureDetector(
        onTap: () => controller.navigateToServiceDetail(service),
        child: Card(
          key: ValueKey(service.applicationId),
          margin: const EdgeInsets.only(bottom: 8),
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
            padding: const EdgeInsets.all(12),
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
                    service.icon,
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
                        service.serviceType,
                        style: AppFonts.bodyText2Style.copyWith(
                          fontWeight: AppFonts.semiBold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Application ID and Status in row
                      Row(
                        children: [
                          // Application ID
                          Expanded(
                            child: Text(
                              'Application No: ${service.applicationId}',
                              style: AppFonts.overlineStyle.copyWith(
                                color: AppColors.fifth,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ),
                          // Status with color
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1,),
                            decoration: BoxDecoration(
                              color: controller.getStatusColor(service.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.getStatusDisplayName(service.status),
                              style: AppFonts.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: AppFonts.regular,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        service.description,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resident Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Horizontal scrollable status tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: RequestStatus.values.length,
              itemBuilder: (context, index) {
                final status = RequestStatus.values[index];
                return _buildStatusTab(status);
              },
            ),
          ),

          // Content area - Service cards list
          Expanded(
            child: Obx(() {
              final services = controller.filteredServices;
              if (services.isEmpty) {
                return Center(
                  child: Text(
                    'No services found for ${controller.getStatusDisplayName(controller.selectedStatus.value).toLowerCase()} status',
                    style: AppFonts.bodyText2Style.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

