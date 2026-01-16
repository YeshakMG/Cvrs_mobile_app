import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';

class CertificateService {
  final String name;
  final String downloadUrl;
  final String type;
  final String? expiryHours;
  final Map<String, dynamic> payload;
  final String? credentialType;
  final String? fileId;
  String? localImagePath;

  CertificateService({
    required this.name,
    required this.downloadUrl,
    required this.type,
    this.expiryHours,
    required this.payload,
    this.credentialType,
    this.fileId,
    this.localImagePath,
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
      fileId: json['fileId']?.toString(),
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
      final response = await ApiService.to.get('my-certificates');
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

        // Download certificates in background
        _downloadAllCertificatesInBackground();
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

  Future<Uint8List?> _generatePdfThumbnail(Uint8List pdfBytes) async {
    try {
      // Verify PDF header
      if (pdfBytes.length < 4) {
        return null;
      }

      final header = pdfBytes.sublist(0, 4);
      if (header[0] != 0x25 || header[1] != 0x50 || header[2] != 0x44 || header[3] != 0x46) {
        return null;
      }

      // Load PDF and render first page
      final document = await PdfDocument.openData(pdfBytes);

      if (document.pagesCount == 0) {
        await document.close();
        return null;
      }

      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: 400,
        height: 600,
        format: PdfPageImageFormat.png,
        quality: 90,
        backgroundColor: '#ffffff',
      );

      await page.close();
      await document.close();

      if (pageImage?.bytes != null && pageImage!.bytes.isNotEmpty) {
        return pageImage.bytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _downloadAllCertificatesInBackground() {
    for (var certificate in certificates) {
      if (certificate.fileId != null && certificate.fileId!.isNotEmpty) {
        _downloadCertificateInBackground(certificate);
      }
    }
  }

  Future<void> _downloadCertificateInBackground(CertificateService certificate) async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/certificates');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      final fileName = '${certificate.name.replaceAll(' ', '_')}_certificate.png';
      final filePath = '${downloadDir.path}/$fileName';

      // Check if already downloaded
      if (await File(filePath).exists()) {
        certificate.localImagePath = filePath;
        certificates.refresh();
        return;
      }

      // Download using the API endpoint
      final downloadDio = Dio(BaseOptions(
        baseUrl: 'https://crrsa-api.risertechservices.com/api/v1/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Add auth token
      if (AuthService.to.accessToken.value.isNotEmpty) {
        downloadDio.options.headers['Authorization'] = 'Bearer ${AuthService.to.accessToken.value}';
      }

      final response = await downloadDio.get(
        'citizen-app-service/files/download?fileId=${certificate.fileId}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is String) {
          // Parse the data string as JSON
          final dataJson = data['data'] as String;
          final parsedData = json.decode(dataJson) as Map<String, dynamic>;
          final downloadUrl = parsedData['downloadUrl'] as String?;

          if (downloadUrl != null) {
            // Now download the actual file from the URL
            final fileResponse = await Dio().get(
              downloadUrl,
              options: Options(
                responseType: ResponseType.bytes,
              ),
            );

            if (fileResponse.statusCode == 200 && fileResponse.data is Uint8List) {
              final fileBytes = fileResponse.data as Uint8List;

              // Generate thumbnail from PDF
              final thumbnailBytes = await _generatePdfThumbnail(fileBytes);

              if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
                // Save thumbnail to file
                final file = File(filePath);
                await file.writeAsBytes(thumbnailBytes);
                print('Thumbnail saved to: $filePath, size: ${thumbnailBytes.length}');

                // Update the certificate with local path
                certificate.localImagePath = filePath;
                certificates.refresh();
                print('Updated certificate localImagePath: $filePath');
              } else {
                print('Failed to generate thumbnail for ${certificate.name}');
              }
            }
          }
        }
      }
    } catch (e) {
      // Silent fail for background download
      print('Background download failed for ${certificate.name}: $e');
    }
  }
}
