import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../../services/api_service.dart';

enum RequestStatus {
  all,
  pending,
  inProgress,
  completed,
  rejected,
  approved,
}

class VitalService {
  final String id;
  final String serviceType;
  final String applicationId;
  final String description;
  final RequestStatus status;
  final IconData icon;

  VitalService({
    required this.id,
    required this.serviceType,
    required this.applicationId,
    required this.description,
    required this.status,
    required this.icon,
  });

  factory VitalService.fromJson(Map<String, dynamic> json) {
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

    // Map request type to service type and icon - Vital services
    IconData icon = Icons.description; // default
    String requestType = json['requestType'] ?? 'Unknown';
    String serviceType = 'Unknown Service';

    switch (requestType.toUpperCase()) {
      case 'BIRTH_SERVICE':
        serviceType = 'Birth Certificate';
        icon = Icons.child_care;
        break;
      case 'MARRIAGE_SERVICE':
        serviceType = 'Marriage Certificate';
        icon = Icons.favorite;
        break;
      case 'ADOPTION_SERVICE':
        serviceType = 'Adoption Certificate';
        icon = Icons.family_restroom;
        break;
      case 'DIVORCE_SERVICE':
        serviceType = 'Divorce Certificate';
        icon = Icons.gavel;
        break;
      case 'DEATH_SERVICE':
        serviceType = 'Death Certificate';
        icon = Icons.anchor;
        break;
      default:
        serviceType = requestType.replaceAll('_', ' ').toLowerCase().replaceAllMapped(
          RegExp(r'\b\w'),
          (match) => match.group(0)!.toUpperCase(),
        );
        break;
    }

    return VitalService(
      id: json['id'] ?? json['applicationId'] ?? 'N/A',
      serviceType: serviceType,
      applicationId: json['applicationId'] ?? json['id'] ?? 'N/A',
      description: json['description'] ?? 'No description available',
      status: status,
      icon: icon,
    );
  }
}

class VitalserviceController extends GetxController {
  final count = 0.obs;
  final selectedStatus = RequestStatus.all.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final RxList<VitalService> allServices = <VitalService>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVitalServices();
  }

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
      case RequestStatus.approved:
        return 'Approved';
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
      case RequestStatus.approved:
        return const Color(0xFF00A650); // Same as completed
    }
  }

  void navigateToServiceDetail(VitalService service) {
    try {
      Get.toNamed(Routes.VITALSERVICE_SERVICE_DETAIL, arguments: service);
    } catch (e) {
      Get.snackbar('Navigation Error', 'Unable to open service details');
    }
  }

  Future<void> fetchVitalServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.to.get('https://crrsa-test.aacrrsa.gov.et/api/v1/portal-bff/my-requests?page=0&size=10');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Vital Services API Response: $data'); // Debug log

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

        // Filter services by request type for vital services
        List<VitalService> vitalServices = [];
        for (var json in servicesJson) {
          if (json is Map<String, dynamic>) {
            String requestType = json['requestType'] ?? '';
            // Vital services include birth, death, marriage, etc.
            if (requestType.toUpperCase().contains('BIRTH') ||
                requestType.toUpperCase().contains('DEATH') ||
                requestType.toUpperCase().contains('MARRIAGE') ||
                requestType.toUpperCase().contains('DIVORCE') ||
                requestType.toUpperCase().contains('ADOPTION')) {
              vitalServices.add(VitalService.fromJson(json));
            }
          }
        }

        print('Parsed ${vitalServices.length} vital services'); // Debug log
        allServices.value = vitalServices;
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
      VitalService(
        id: 'sample-vital-id-1',
        serviceType: 'Birth Certificate',
        applicationId: 'CRRSA-20251202193636',
        description: 'Birth certificate registration',
        status: RequestStatus.approved,
        icon: Icons.child_care,
      ),
      VitalService(
        id: 'sample-vital-id-2',
        serviceType: 'Death Certificate',
        applicationId: 'CRRSA-20251202195548',
        description: 'Status changed to APPROVED',
        status: RequestStatus.approved,
        icon: Icons.anchor,
      ),
    ];
  }
}
