import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/vitalservice_controller.dart';
import '../../../../../services/api_service.dart';

class StatusLog {
  final String status;
  final DateTime updatedAt;
  final String? remark;
  final DateTime? requestedAt;

  StatusLog({
    required this.status,
    required this.updatedAt,
    this.remark,
    this.requestedAt,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) {
    return StatusLog(
      status: json['status'] ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      remark: json['remark'],
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : null,
    );
  }
}

class ServiceDetailController extends GetxController {
  final count = 0.obs;
  late VitalService service;

  final RxBool isLoading = true.obs;
  final RxList<StatusLog> statusLogs = <StatusLog>[].obs;
  final Rx<DateTime?> createdAt = Rx<DateTime?>(null);

  final List<String> steps = [
    'Application Submit',
    'Document Verification',
    'Document Authorization',
    'Ready to Collect',
  ];

  List<String> get stepDescriptions {
    if (statusLogs.isEmpty) {
      // Fallback to default descriptions if no status logs available
      String firstDescription = 'Successfully submitted';
      if (createdAt.value != null) {
        final formattedDate = DateFormat('dd-MM-yyyy').format(createdAt.value!);
        firstDescription = '$firstDescription on $formattedDate';
      }
      return [
        firstDescription,
        'Successfully verified',
        'Successfully authorized',
        'Successfully completed',
      ];
    }

    // Sort status logs by timestamp (requestedAt or updatedAt)
    final sortedLogs = statusLogs.toList()..sort((a, b) {
      final aTime = a.requestedAt ?? a.updatedAt;
      final bTime = b.requestedAt ?? b.updatedAt;
      return aTime.compareTo(bTime);
    });

    // Create descriptions based on status logs
    final descriptions = <String>[];

    // First step: Application Submit - use createdAt if available
    if (createdAt.value != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(createdAt.value!);
      descriptions.add('${steps[0]} on $formattedDate');
    } else if (sortedLogs.isNotEmpty) {
      final log = sortedLogs[0];
      final timestamp = log.requestedAt ?? log.updatedAt;
      final formattedDate = DateFormat('dd-MM-yyyy').format(timestamp);
      descriptions.add('${steps[0]} on $formattedDate');
    } else {
      descriptions.add(steps[0]);
    }

    // Remaining steps
    int logIndex = createdAt.value != null ? 0 : 1;
    for (int i = 1; i < steps.length; i++) {
      if (logIndex < sortedLogs.length) {
        final log = sortedLogs[logIndex];
        final timestamp = log.requestedAt ?? log.updatedAt;
        final formattedDate = DateFormat('dd-MM-yyyy').format(timestamp);
        descriptions.add('${steps[i]} on $formattedDate');
        logIndex++;
      } else {
        descriptions.add(steps[i]);
      }
    }

    // Fill remaining steps if needed
    while (descriptions.length < steps.length) {
      descriptions.add(steps[descriptions.length]);
    }

    return descriptions;
  }

  @override
  void onInit() {
    super.onInit();
    // Get the service passed as argument
    if (Get.arguments != null && Get.arguments is VitalService) {
      service = Get.arguments as VitalService;
      fetchServiceDetail();
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
      case RequestStatus.approved:
        return 3; // Ready to Collect (approved is similar to completed)
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
      case RequestStatus.approved:
        return 'Approved';
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
      case RequestStatus.approved:
        return const Color(0xFF00A650); // Same as completed
      case RequestStatus.rejected:
        return const Color(0xFFD32F2F); // Red accent
    }
  }

  Future<void> fetchServiceDetail() async {
    try {
      isLoading.value = true;

      final response = await ApiService.to.get(
        'https://crrsa-test.aacrrsa.gov.et/api/v1/portal-bff/my-requests/${service.id}/detail?page=0&size=10'
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Service Detail API Response: $responseData'); // Debug log

        // Handle API response structure: {success: true, message: "...", data: {...}}
        Map<String, dynamic>? serviceData;

        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          serviceData = responseData['data'] as Map<String, dynamic>?;
        } else if (responseData is Map<String, dynamic>) {
          serviceData = responseData;
        }

        if (serviceData != null && serviceData.containsKey('statusLogs')) {
          final statusLogsJson = serviceData['statusLogs'] as List<dynamic>? ?? [];

          // Parse status logs
          statusLogs.value = statusLogsJson
              .where((json) => json is Map<String, dynamic>)
              .map((json) => StatusLog.fromJson(json))
              .toList();

          print('Parsed ${statusLogs.length} status logs'); // Debug log

          // Parse createdAt
          if (serviceData.containsKey('createdAt') && serviceData['createdAt'] != null) {
            createdAt.value = DateTime.parse(serviceData['createdAt']);
            print('Parsed createdAt: ${createdAt.value}'); // Debug log
          } else {
            createdAt.value = null;
          }
        } else {
          print('No statusLogs found in response');
          statusLogs.value = [];
          createdAt.value = null;
        }
      } else {
        Get.snackbar('Error', 'Failed to load service details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching service detail: $e');
      Get.snackbar('Error', 'Error fetching service details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void increment() => count.value++;
}