import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../controllers/vitalservice_controller.dart';

class VitalserviceView extends GetView<VitalserviceController> {
  const VitalserviceView({super.key});

  Widget _buildStatusTab(RequestStatus status, bool isTablet) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      return GestureDetector(
        onTap: () => controller.selectStatus(status),
        child: Container(
          key: ValueKey(status),
          margin: EdgeInsets.only(right: isTablet ? 16 : 12),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 12 : 8,
          ),
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
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildServiceCard(VitalService service, bool isTablet) {
    return Semantics(
      label: 'Service card for ${service.serviceType}',
      child: GestureDetector(
        onTap: () => controller.navigateToServiceDetail(service),
        child: Card(
          key: ValueKey(service.applicationId),
          margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
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
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service.icon,
                    size: isTablet ? 32 : 28,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
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
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      // Application ID and Status in row
                      Row(
                        children: [
                          // Application ID
                          Expanded(
                            child: Text(
                              'Application ID: ${service.applicationId}',
                              style: AppFonts.overlineStyle.copyWith(
                                color: AppColors.fifth,
                                fontWeight: AppFonts.bold,
                                fontSize: isTablet ? 13 : 12,
                              ),
                            ),
                          ),
                          // Status with color
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : 8,
                              vertical: isTablet ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: controller.getStatusColor(service.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.getStatusDisplayName(service.status),
                              style: AppFonts.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: AppFonts.regular,
                                fontSize: isTablet ? 12 : 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      // Description
                      Text(
                        service.description,
                        style: AppFonts.captionStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 13 : 12,
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
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'Vital Service',
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
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
          final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);

          return Column(
        children: [
          // Horizontal scrollable status tabs
          Container(
            height: isTablet ? 60 : 50,
            margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: RequestStatus.values.length,
              itemBuilder: (context, index) {
                final status = RequestStatus.values[index];
                return _buildStatusTab(status, isTablet);
              },
            ),
          ),

          // Content area - Service cards list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: AppFonts.bodyText2Style.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchVitalServices(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final services = controller.filteredServices;
              if (services.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Text(
                      'No services found for ${controller.getStatusDisplayName(controller.selectedStatus.value).toLowerCase()} status',
                      style: AppFonts.bodyText2Style.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service, isTablet);
                },
              );
            }),
          ),
        ],
      );
    },
  ),
);
  }
}
