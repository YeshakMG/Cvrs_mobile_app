import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/api_service.dart';

enum RequestStatus {
  all,
  pending,
  inProgress,
  completed,
  rejected,
  approved,
}

class ResidentService {
  final String id;
  final String serviceType;
  final String applicationId;
  final String description;
  final RequestStatus status;
  final IconData icon;
  final String? rejectionReason;
  final String? rejectionDate;

  ResidentService({
    required this.id,
    required this.serviceType,
    required this.applicationId,
    required this.description,
    required this.status,
    required this.icon,
    this.rejectionReason,
    this.rejectionDate,
  });

  factory ResidentService.fromJson(Map<String, dynamic> json) {
    // Assuming API response structure - adjust based on actual response
    String statusString = json['status'] ?? 'pending';
    RequestStatus status = RequestStatus.pending; // default

    switch (statusString.toLowerCase()) {
      case 'pending':
        status = RequestStatus.pending;
        break;
      case 'in_progress':
      case 'inprogress':
        status = RequestStatus.inProgress;
        break;
      case 'completed':
        status = RequestStatus.completed;
        break;
      case 'rejected':
        status = RequestStatus.rejected;
        break;
      case 'approved':
        status = RequestStatus.approved;
        break;
    }

    // Map request type to service type and icon
    IconData icon = Icons.description; // default
    String requestType = json['requestType'] ?? 'Unknown';
    String serviceType = 'Unknown Service';

    switch (requestType.toUpperCase()) {
      case 'ID_PRINTING':
        serviceType = 'ID Printing';
        icon = Icons.credit_card;
        break;
      case 'REGULAR_RESIDENT':
        serviceType = 'Regular Resident Registration';
        icon = Icons.person;
        break;
      case 'FAMILY_REGISTRATION':
        serviceType = 'Family Registration';
        icon = Icons.people;
        break;
      case 'RESIDENCE_TRANSFER':
        serviceType = 'Residence Transfer';
        icon = Icons.home;
        break;
      case 'UNMARRIED_CERTIFICATE':
        serviceType = 'Unmarried Certificate';
        icon = Icons.description;
        break;
      default:
        serviceType = requestType.replaceAll('_', ' ').toLowerCase().replaceAllMapped(
          RegExp(r'\b\w'),
          (match) => match.group(0)!.toUpperCase(),
        );
        break;
    }

    return ResidentService(
      id: json['id'] ?? json['applicationId'] ?? 'N/A',
      serviceType: serviceType,
      applicationId: json['applicationId'] ?? json['id'] ?? 'N/A',
      description: json['description'] ?? 'No description available',
      status: status,
      icon: icon,
      rejectionReason: json['rejectionReason'],
      rejectionDate: json['rejectionDate'],
    );
  }
}

class ResidentidController extends GetxController {
  final count = 0.obs;
  final selectedStatus = RequestStatus.all.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final RxList<ResidentService> allServices = <ResidentService>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchResidentServices();
  }

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
      case RequestStatus.approved:
        return 'Approved';
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
      case RequestStatus.approved:
        return const Color(0xFF00A650); // Same as completed
    }
  }

  void navigateToServiceDetail(ResidentService service) {
    try {
      Get.toNamed('/residentid/service-detail', arguments: service);
    } catch (e) {
      Get.snackbar('Navigation Error', 'Unable to open service details');
    }
  }

  Future<void> fetchResidentServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.to.get('https://crrsa-test.aacrrsa.gov.et/api/v1/portal-bff/my-requests?page=0&size=10');

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data'); // Debug log

        // Handle API response structure: {success: true, message: "...", data: [...], metadata: {...}}
        List<dynamic> servicesJson = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          servicesJson = data['data'] ?? [];
        } else if (data is List) {
          servicesJson = data;
        }

        // Ensure we have a list
        if (servicesJson is! List) {
          print('Warning: servicesJson is not a List, type: ${servicesJson.runtimeType}');
          servicesJson = [];
        }

        // Filter out vital services - only show resident services
        List<dynamic> residentServicesJson = [];
        for (var json in servicesJson) {
          if (json is Map<String, dynamic>) {
            String requestType = json['requestType'] ?? '';
            // Exclude vital services from resident services
            if (!(requestType.toUpperCase().contains('BIRTH') ||
                  requestType.toUpperCase().contains('DEATH') ||
                  requestType.toUpperCase().contains('MARRIAGE') ||
                  requestType.toUpperCase().contains('DIVORCE') ||
                  requestType.toUpperCase().contains('ADOPTION'))) {
              residentServicesJson.add(json);
            }
          }
        }

        print('Parsed ${residentServicesJson.length} resident services'); // Debug log
        allServices.value = residentServicesJson.map((json) => ResidentService.fromJson(json)).toList();
      } else {
        errorMessage.value = 'Failed to load services: ${response.statusCode}';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error fetching services: $e';
      Get.snackbar('Error', errorMessage.value);
      // Fallback to sample data for development
      _loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadSampleData() {
    allServices.value = [
      ResidentService(
        id: '75a6677f-6057-4fae-bcdd-4a670dece0a6',
        serviceType: 'ID Printing',
        applicationId: 'BATCH-1764737355217',
        description: 'ID printing request for batch processing - Print ID: 6ddec3fe-b05a-439f-8a24-0322c6d77c45',
        status: RequestStatus.pending,
        icon: Icons.credit_card,
      ),
      ResidentService(
        id: 'sample-id-2',
        serviceType: 'Regular Resident Registration',
        applicationId: 'CRRSA-20251202134020',
        description: 'New resident registration request for AA0000122288',
        status: RequestStatus.pending,
        icon: Icons.person,
      ),
    ];
  }
}
