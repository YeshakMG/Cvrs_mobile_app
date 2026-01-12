import 'package:get/get.dart';
import '../../../../services/api_service.dart';

class CertificateService {
  final String name;
  final String downloadUrl;
  final String type;
  final String? expiryHours;
  final Map<String, dynamic> payload;
  final String? credentialType;

  CertificateService({
    required this.name,
    required this.downloadUrl,
    required this.type,
    this.expiryHours,
    required this.payload,
    this.credentialType,
  });

  static CertificateService? fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? {};
    final credentialData = payload['credentialData'] as Map<String, dynamic>? ?? {};

    // Determine certificate type and name based on payload data
    String? type;
    String? name;
    String? credentialTypeValue = payload['credentialType']?.toString();

    if (credentialTypeValue == 'BIRTH_CERT' || credentialData['Registration Number'] != null) {
      type = 'Vital';
      name = 'Birth Certificate';
    } else if (payload['subjectId'] != null && payload['subjectId'].toString().startsWith('ID/')) {
      type = 'Resident';
      name = 'Resident ID Certificate';
    } else if (credentialTypeValue != null) {
      // Use credentialType to determine name
      switch (credentialTypeValue) {
        case 'BIRTH_CERT':
          name = 'Birth Certificate';
          type = 'Vital';
          break;
        // Add other cases as needed
        default:
          // Unknown credentialType, don't create certificate
          return null;
      }
    } else {
      // No identifiable type, don't create certificate
      return null;
    }

    if (type == null || name == null) {
      return null;
    }

    return CertificateService(
      name: name,
      downloadUrl: json['fileUrl'] ?? '',
      type: type,
      expiryHours: json['expiryDate']?.toString(),
      payload: payload,
      credentialType: payload['credentialType']?.toString(),
    );
  }
}

class DigitalcertificatesController extends GetxController {
  final count = 0.obs;
  final selectedServiceType = 'All'.obs;
  final serviceTypes = ['All', 'Vital', 'Resident'].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final certificates = <CertificateService>[].obs;

  List<CertificateService> get filteredCertificates {
    if (selectedServiceType.value == 'All') {
      return certificates;
    }
    return certificates.where((cert) => cert.type == selectedServiceType.value).toList();
  }

  Future<void> fetchCertificates() async {
    print('DEBUG: fetchCertificates called');
    try {
      print('DEBUG: Setting loading to true');
      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Making API call to citizen-app-service/my-certificates');
      final response = await ApiService.to.get('citizen-app-service/my-certificates');
      print('DEBUG: API call completed, status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Certificates API Response: $data');

        // Handle API response structure: {success: true, message: "...", data: [...], metadata: {...}}
        List<dynamic> certificatesJson = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
           certificatesJson = data['data'] ?? [];
         } else if (data is List) {
           certificatesJson = data;
         }

         print('Certificates API Response Data: $certificatesJson');

        if (certificatesJson is! List) {
          certificatesJson = [];
        }

        // Parse certificates directly from the response
        List<CertificateService> foundCertificates = [];
        for (var json in certificatesJson) {
          if (json is Map<String, dynamic>) {
            final cert = CertificateService.fromJson(json);
            if (cert != null) foundCertificates.add(cert);
          }
        }

        certificates.value = foundCertificates;
      } else {
        errorMessage.value = 'Failed to load certificates: ${response.statusCode}';
      }
    } catch (e) {
      print('DEBUG: Exception in fetchCertificates: $e');
      errorMessage.value = 'Error fetching certificates: $e';
      print('Certificates error: $e');
    } finally {
      print('DEBUG: Setting loading to false');
      isLoading.value = false;
    }
  }



  @override
  void onReady() {
    print('DEBUG: DigitalcertificatesController onReady called');
    super.onReady();
    fetchCertificates();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
