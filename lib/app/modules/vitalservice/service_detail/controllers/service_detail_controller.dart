import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/vitalservice_controller.dart';

class ServiceDetailController extends GetxController {
  //TODO: Implement ServiceDetailController

  final count = 0.obs;
  late VitalService service;

  final List<String> steps = [
    'Application Submit',
    'Document Verification',
    'Document Authorization',
    'Ready to Collect',
  ];

  final List<String> stepDescriptions = [
    'Successfully submitted on 02-08-2025',
    'Successfully verified on 05-08-2025',
    'Successfully authorized on 10-08-2025',
    'Successfully completed on 15-08-2025',
  ];

  @override
  void onInit() {
    super.onInit();
    // Get the service passed as argument
    if (Get.arguments != null && Get.arguments is VitalService) {
      service = Get.arguments as VitalService;
    } else {
      // Handle case where service is not passed - redirect back or show error
      Get.back();
      Get.snackbar('Error', 'Service information not found');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  int getCurrentStep() {
    switch (service.status) {
      case RequestStatus.pending:
        return 0; // Application Submitted
      case RequestStatus.inProgress:
        return 1; // Document Verified
      case RequestStatus.completed:
        return 3; // Ready to Collect
      case RequestStatus.rejected:
        return 1; // Document Verified (but rejected)
      default:
        return 0;
    }
  }

  bool isStepCompleted(int stepIndex) {
    return stepIndex <= getCurrentStep();
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
        return const Color(0xFFD32F2F); // Red accent
    }
  }
  void increment() => count.value++;
}