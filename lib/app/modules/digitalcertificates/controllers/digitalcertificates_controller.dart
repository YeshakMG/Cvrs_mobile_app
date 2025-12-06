import 'package:get/get.dart';
import '../../../../services/api_service.dart';

class CertificateService {
  final String name;
  final String downloadUrl;
  final String type;
  final String? expiryHours;

  CertificateService({
    required this.name,
    required this.downloadUrl,
    required this.type,
    this.expiryHours,
  });

  factory CertificateService.fromJson(Map<String, dynamic> json) {
    return CertificateService(
      name: json['name'] ?? 'Digital Certificate',
      downloadUrl: json['downloadUrl'] ?? '',
      type: json['type'] ?? 'Certificate',
      expiryHours: json['expiryHours']?.toString(),
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

      print('DEBUG: Making API call to https://crrsa-test.aacrrsa.gov.et/api/v1/portal-bff/my-certificates');
      final response = await ApiService.to.get('https://crrsa-test.aacrrsa.gov.et/api/v1/portal-bff/my-certificates', queryParameters: {
        'page': 0,
        'size': 10,
      });
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

        if (certificatesJson is! List) {
          certificatesJson = [];
        }

        // Parse certificates directly from the response
        List<CertificateService> foundCertificates = [];
        for (var json in certificatesJson) {
          if (json is Map<String, dynamic>) {
            foundCertificates.add(CertificateService.fromJson(json));
          }
        }

        if (foundCertificates.isEmpty) {
          // Fallback to sample data if no certificates found
          _loadSampleData();
        } else {
          certificates.value = foundCertificates;
        }
      } else {
        errorMessage.value = 'Failed to load certificates: ${response.statusCode}';
        _loadSampleData();
      }
    } catch (e) {
      print('DEBUG: Exception in fetchCertificates: $e');
      errorMessage.value = 'Error fetching certificates: $e';
      print('Certificates error: $e');
      _loadSampleData();
    } finally {
      print('DEBUG: Setting loading to false');
      isLoading.value = false;
    }
  }


  void _loadSampleData() {
    // Sample data - test with real signed URL
    certificates.value = [
      CertificateService(
        name: 'Test Certificate',
        downloadUrl: 'https://crrsa-storage-test.aacrrsa.gov.et/public-files/f0444b18-65d6-4ed3-9f95-b609b8332599.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=5h6upTqkKAP1%2F20251203%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251203T081538Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=41518d7548131c4b68dae7d4875d358228463a6504a04c126228a958c9123d8d',
        type: 'Test',
      ),
      CertificateService(
        name: 'Birth Certificate',
        downloadUrl: '', // Empty URL - will show icon
        type: 'Vital',
      ),
      CertificateService(
        name: 'Death Certificate',
        downloadUrl: '', // Empty URL - will show icon
        type: 'Vital',
      ),
      CertificateService(
        name: 'Marriage Certificate',
        downloadUrl: '', // Empty URL - will show icon
        type: 'Vital',
      ),
      CertificateService(
        name: 'Resident ID',
        downloadUrl: '', // Empty URL - will show icon
        type: 'Resident',
      ),
    ];
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
