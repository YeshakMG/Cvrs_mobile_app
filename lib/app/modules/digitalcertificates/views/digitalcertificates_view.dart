import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../../../../services/api_service.dart';
import '../controllers/digitalcertificates_controller.dart';

class DigitalcertificatesView extends GetView<DigitalcertificatesController> {
  const DigitalcertificatesView({super.key});

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
              'Digital Certificates',
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
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final maxWidth = isMobile ? double.infinity :
                            isTablet ? constraints.maxWidth * 0.7 :
                            constraints.maxWidth * 0.5;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Loading Indicator
                        Obx(() => controller.isLoading.value
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink()),

                        // Error Message
                        Obx(() => controller.errorMessage.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppFonts.bodyText2Style.copyWith(
                                    color: Colors.red[800],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),

                        // Service Type Dropdown
                        Text(
                          'Select Certificate Type',
                          style: AppFonts.bodyText1Style.copyWith(
                            fontWeight: AppFonts.regular,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: controller.selectedServiceType.value == 'All'
                              ? null
                              : controller.selectedServiceType.value,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),

                          // 👇 Hint text when nothing selected
                          hint: Text(
                            'All Certificates',
                            style: AppFonts.bodyText1Style.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          // 👇 Dropdown list items with font size
                          items: controller.serviceTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: AppFonts.bodyText1Style.copyWith(
                                  fontSize: 14, // adjust this for your desired size
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),

                          onChanged: (String? newValue) {
                            controller.selectedServiceType.value = newValue ?? 'All';
                          },
                        ),
                      )),

                        const SizedBox(height: 24),

                        // Certificates List or Empty State
                        Obx(() {
                          if (controller.certificates.isEmpty && !controller.isLoading.value) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Certificates Found',
                                    style: AppFonts.bodyText1Style.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete a service request to receive certificates',
                                    style: AppFonts.bodyText2Style.copyWith(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredCertificates.length,
                            itemBuilder: (context, index) {
                              final certificate = controller.filteredCertificates[index];
                              return _buildCertificateCard(certificate);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
Widget _buildCertificateCard(CertificateService certificate) {
  return Container(
    margin: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 5), // lowered card
    padding: const EdgeInsets.all(2),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Certificate image/thumbnail
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: certificate.downloadUrl.isNotEmpty
                  ? FutureBuilder<Uint8List>(
                      future: _getPdfThumbnail(certificate.downloadUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )),
                          );
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                          print('PDF thumbnail error for URL: ${certificate.downloadUrl}');
                          print('Error details: ${snapshot.error}');
                          return Container(
                            color: Colors.red[50],
                            child: const Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                          );
                        } else {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.red[50],
                              child: const Icon(
                                Icons.picture_as_pdf,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : const Icon(Icons.description, size: 40, color: Colors.grey),
          ),
        ),

        const SizedBox(width: 10),

        // Certificate details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                certificate.name,
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.regular,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Type: ${certificate.type}',
                style: AppFonts.bodyText2Style.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (certificate.expiryHours != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Expires in: ${certificate.expiryHours} hours',
                  style: AppFonts.bodyText2Style.copyWith(
                    color: Colors.orange[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 5),

              // ✅ Horizontal icons: Preview | Share | Download
              Row(
                children: [
                  IconButton(
                    onPressed: () => _previewCertificate(certificate),
                    icon: const Icon(Icons.visibility,
                        color: AppColors.primary, size: 18),
                    splashRadius: 22,
                  ),
                  IconButton(
                    onPressed: () => _shareCertificate(certificate),
                    icon: const Icon(Icons.share,
                        color: AppColors.primary, size: 18),
                    splashRadius: 22,
                  ),
                  IconButton(
                    onPressed: () => _downloadCertificate(certificate),
                    icon: const Icon(Icons.download,
                        color: AppColors.primary, size: 18),
                    splashRadius: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  void _shareCertificate(CertificateService certificate) {
    Share.share(
      'Check out this ${certificate.name} from ${certificate.type} services!',
      subject: certificate.name,
    );
  }

  Future<void> _downloadCertificate(CertificateService certificate) async {
    if (certificate.downloadUrl.isEmpty) {
      Get.snackbar(
        'Download Unavailable',
        'No download URL available for ${certificate.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Show loading
      Get.snackbar(
        'Downloading',
        'Downloading ${certificate.name}...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${certificate.name.replaceAll(' ', '_')}.pdf';
      final filePath = '${directory.path}/$fileName';

      print('Download - Starting download for: ${certificate.downloadUrl}');

      // Get the PDF data with proper decoding and AWS headers
      final response = await Dio().get(
        certificate.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
            // AWS S3 signed URL headers
            'X-Amz-Algorithm': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Algorithm'),
            'X-Amz-Credential': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Credential'),
            'X-Amz-Date': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Date'),
            'X-Amz-Expires': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Expires'),
            'X-Amz-SignedHeaders': _extractAwsParam(certificate.downloadUrl, 'X-Amz-SignedHeaders'),
            'X-Amz-Signature': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Signature'),
          },
        ),
      );
      final data = response.data;

      print('Download - Response data type: ${data.runtimeType}, length: ${data is Uint8List ? data.length : 'N/A'}');

      Uint8List pdfBytes;
      if (data is String) {
        // If response is string, try base64 decoding
        try {
          pdfBytes = base64Decode(data);
          print('Download - Successfully decoded base64, length: ${pdfBytes.length}');
        } catch (e) {
          print('Download - Base64 decode failed, using as-is: $e');
          pdfBytes = Uint8List.fromList(utf8.encode(data));
        }
      } else if (data is Uint8List) {
        pdfBytes = data;
        print('Download - Data is already Uint8List, length: ${pdfBytes.length}');
      } else {
        throw 'Invalid PDF data format';
      }

      // Save to file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      print('Download - File saved to: $filePath');

      // Show success and offer to open
      Get.snackbar(
        'Download Complete',
        'File saved to: $filePath',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () async {
            final file = File(filePath);
            if (await file.exists()) {
              // Try to open the file
              final url = Uri.file(filePath);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                Get.snackbar(
                  'Open File',
                  'Unable to open file automatically',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            }
          },
          child: const Text('Open', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      print('Download error: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        Get.snackbar(
          'Download Failed',
          'File not accessible (404). The download link may have expired.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Download Failed',
          'Error downloading ${certificate.name}: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }


  Future<Uint8List> _getPdfThumbnail(String url) async {
    try {
      print('PDF Thumbnail - Downloading PDF from URL: $url');

      // Download PDF data with common headers
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
          },
        ),
      );
      final data = response.data;

      print('PDF Thumbnail - Downloaded data type: ${data.runtimeType}, length: ${data is Uint8List ? data.length : 'N/A'}');

      Uint8List pdfBytes;
      if (data is String) {
        // If response is string, try base64 decoding
        try {
          pdfBytes = base64Decode(data);
          print('PDF Thumbnail - Successfully decoded base64, length: ${pdfBytes.length}');
        } catch (e) {
          print('PDF Thumbnail - Base64 decode failed, using as-is: $e');
          pdfBytes = Uint8List.fromList(utf8.encode(data));
        }
      } else if (data is Uint8List) {
        pdfBytes = data;
        print('PDF Thumbnail - Data is already Uint8List, length: ${pdfBytes.length}');
      } else {
        print('PDF Thumbnail - Unknown data type: ${data.runtimeType}');
        return Uint8List(0);
      }

      // Verify PDF header
      if (pdfBytes.length < 4) {
        print('PDF Thumbnail - Data too short to be PDF');
        return Uint8List(0);
      }

      final header = pdfBytes.sublist(0, 4);
      print('PDF Thumbnail - First 4 bytes: ${header.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      if (header[0] == 0x25 && header[1] == 0x50 && header[2] == 0x44 && header[3] == 0x46) {
        print('PDF Thumbnail - Valid PDF header detected');
      } else {
        print('PDF Thumbnail - Invalid PDF header, not a PDF file');
        return Uint8List(0);
      }

      print('PDF Thumbnail - Opening PDF document...');
      // Load PDF and render first page
      final document = await PdfDocument.openData(pdfBytes);
      print('PDF Thumbnail - PDF opened, pages: ${document.pagesCount}');

      if (document.pagesCount == 0) {
        print('PDF Thumbnail - PDF has no pages');
        await document.close();
        return Uint8List(0);
      }

      final page = await document.getPage(1);
      print('PDF Thumbnail - Rendering page 1...');

      final pageImage = await page.render(
        width: 80,
        height: 80,
        format: PdfPageImageFormat.jpeg,
        quality: 75,
        backgroundColor: '#ffffff',
      );

      await page.close();
      await document.close();

      if (pageImage?.bytes != null && pageImage!.bytes.isNotEmpty) {
        print('PDF Thumbnail - Successfully rendered thumbnail, size: ${pageImage.bytes.length}');
        return pageImage.bytes;
      } else {
        print('PDF Thumbnail - Render returned null or empty');
        return Uint8List(0);
      }
    } catch (e) {
      print('PDF Thumbnail - Error generating thumbnail: $e');
      // Check if it's a 404 error
      if (e is DioException && e.response?.statusCode == 404) {
        print('PDF Thumbnail - 404 error: PDF URL not accessible, showing icon instead');
      }
      return Uint8List(0);
    }
  }

  String _extractAwsParam(String url, String paramName) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters[paramName] ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<Uint8List> _generatePdfPreviewImage(Uint8List pdfBytes) async {
    try {
      print('Generating PDF preview image from ${pdfBytes.length} bytes');

      // Verify PDF header
      if (pdfBytes.length < 4) {
        print('PDF data too short');
        return Uint8List(0);
      }

      final header = pdfBytes.sublist(0, 4);
      if (header[0] != 0x25 || header[1] != 0x50 || header[2] != 0x44 || header[3] != 0x46) {
        print('Invalid PDF header');
        return Uint8List(0);
      }

      // Load PDF and render first page
      final document = await PdfDocument.openData(pdfBytes);
      print('PDF opened, pages: ${document.pagesCount}');

      if (document.pagesCount == 0) {
        await document.close();
        return Uint8List(0);
      }

      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: 300,
        height: 400,
        format: PdfPageImageFormat.jpeg,
        quality: 80,
        backgroundColor: '#ffffff',
      );

      await page.close();
      await document.close();

      if (pageImage?.bytes != null && pageImage!.bytes.isNotEmpty) {
        print('Successfully generated PDF preview image, size: ${pageImage.bytes.length}');
        return pageImage.bytes;
      } else {
        print('PDF render returned empty image');
        return Uint8List(0);
      }
    } catch (e) {
      print('Error generating PDF preview image: $e');
      return Uint8List(0);
    }
  }

  void _previewCertificate(CertificateService certificate) async {
    if (certificate.downloadUrl.isEmpty) {
      Get.snackbar(
        'Preview Unavailable',
        'No certificate URL available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Download PDF content
      final response = await Dio().get(
        certificate.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
            'X-Amz-Algorithm': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Algorithm'),
            'X-Amz-Credential': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Credential'),
            'X-Amz-Date': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Date'),
            'X-Amz-Expires': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Expires'),
            'X-Amz-SignedHeaders': _extractAwsParam(certificate.downloadUrl, 'X-Amz-SignedHeaders'),
            'X-Amz-Signature': _extractAwsParam(certificate.downloadUrl, 'X-Amz-Signature'),
          },
        ),
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200 && response.data is Uint8List) {
        final pdfBytes = response.data as Uint8List;

        // Show PDF preview dialog with actual PDF viewer
        Get.dialog(
          Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.8,
                maxWidth: Get.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    certificate.name,
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.semiBold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: FutureBuilder<Uint8List>(
                      future: _generatePdfPreviewImage(pdfBytes),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                                SizedBox(height: 8),
                                Text(
                                  'PDF Preview',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Certificate loaded successfully',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Get.back();
                          await _downloadCertificate(certificate);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'Preview Failed',
          'Unable to load certificate preview',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      print('Preview error: $e');
      Get.snackbar(
        'Preview Failed',
        'Error loading certificate: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
