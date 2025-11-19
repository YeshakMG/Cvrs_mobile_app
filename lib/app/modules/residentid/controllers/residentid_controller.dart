import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum RequestStatus {
  all,
  pending,
  inProgress,
  completed,
  rejected,
}

class ResidentService {
  final String serviceType;
  final String applicationId;
  final String description;
  final RequestStatus status;
  final IconData icon;
  final String? rejectionReason;
  final String? rejectionDate;

  ResidentService({
    required this.serviceType,
    required this.applicationId,
    required this.description,
    required this.status,
    required this.icon,
    this.rejectionReason,
    this.rejectionDate,
  });
}

class ResidentidController extends GetxController {
  final count = 0.obs;
  final selectedStatus = RequestStatus.all.obs;

  final List<ResidentService> allServices = [
    ResidentService(
      serviceType: 'Residence ID',
      applicationId: 'RID-2024-001',
      description: 'Application for residence identification card',
      status: RequestStatus.completed,
      icon: Icons.credit_card, // ID card-like icon
    ),
    ResidentService(
      serviceType: 'Family Registration',
      applicationId: 'FR-2024-002',
      description: 'Family registration certificate request',
      status: RequestStatus.pending,
      icon: Icons.people, // Family icon
    ),
    ResidentService(
      serviceType: 'Residence Transfer',
      applicationId: 'RT-2024-003',
      description: 'Transfer of residence to new location',
      status: RequestStatus.inProgress,
      icon: Icons.home, // Home transfer icon
    ),
    ResidentService(
      serviceType: 'Unmarried Certificate',
      applicationId: 'UC-2024-004',
      description: 'Certificate of unmarried status',
      status: RequestStatus.rejected,
      icon: Icons.description, // Document/certificate icon
      rejectionReason: 'Incomplete documentation - missing proof of address',
      rejectionDate: '15-08-2025',
    ),
  ];

  List<ResidentService> get filteredServices {
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
        return const Color(0xFF073C59); // Primary color
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

  void navigateToServiceDetail(ResidentService service) {
    try {
      Get.toNamed('/residentid/service-detail', arguments: service);
    } catch (e) {
      Get.snackbar('Navigation Error', 'Unable to open service details');
    }
  }
}
