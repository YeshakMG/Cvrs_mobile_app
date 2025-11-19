import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

enum RequestStatus {
  all,
  pending,
  inProgress,
  completed,
  rejected,
}

class VitalService {
  final String serviceType;
  final String applicationId;
  final String description;
  final RequestStatus status;
  final IconData icon;

  VitalService({
    required this.serviceType,
    required this.applicationId,
    required this.description,
    required this.status,
    required this.icon,
  });
}

class VitalserviceController extends GetxController {
  final count = 0.obs;
  final selectedStatus = RequestStatus.all.obs;

  final List<VitalService> allServices = [
    VitalService(
      serviceType: 'Birth',
      applicationId: 'BR-2024-001',
      description: 'Birth certificate registration',
      status: RequestStatus.completed,
      icon: Icons.child_care, // Represents birth/child
    ),
    VitalService(
      serviceType: 'Marriage',
      applicationId: 'MR-2024-002',
      description: 'Marriage certificate application',
      status: RequestStatus.pending,
      icon: Icons.favorite, // Represents love/marriage
    ),
    VitalService(
      serviceType: 'Adoption',
      applicationId: 'AD-2024-003',
      description: 'Child adoption registration',
      status: RequestStatus.inProgress,
      icon: Icons.family_restroom, // Represents family/adoption
    ),
    VitalService(
      serviceType: 'Divorce',
      applicationId: 'DV-2024-004',
      description: 'Divorce certificate application',
      status: RequestStatus.rejected,
      icon: Icons.gavel, // Represents breakup/divorce (appropriate emotion icon)
    ),
    VitalService(
      serviceType: 'Death',
      applicationId: 'DT-2024-005',
      description: 'Death certificate registration',
      status: RequestStatus.completed,
      icon: Icons.anchor, // Or use Icons.sentiment_very_dissatisfied or Icons.cemetery (closest available)
    ),
  ];

  List<VitalService> get filteredServices {
    if (selectedStatus.value == RequestStatus.all) {
      return allServices;
    }
    return allServices
        .where((service) => service.status == selectedStatus.value)
        .toList();
  }

  void increment() => count.value++;

  void selectStatus(RequestStatus status) {
    selectedStatus.value = status;
  }

  String getStatusDisplayName(RequestStatus status) {
    switch (status) {
      case RequestStatus.all:
        return 'All';
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  Color getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.all:
        return const Color(0xFF073C59);
      case RequestStatus.pending:
        return const Color(0xFFAAAAAA);
      case RequestStatus.inProgress:
        return const Color(0xFFF7941D);
      case RequestStatus.completed:
        return const Color(0xFF00A650);
      case RequestStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }

  void navigateToServiceDetail(VitalService service) {
    try {
      Get.toNamed(Routes.VITALSERVICE_SERVICE_DETAIL, arguments: service);
    } catch (e) {
      Get.snackbar('Navigation Error', 'Unable to open service details');
    }
  }
}
