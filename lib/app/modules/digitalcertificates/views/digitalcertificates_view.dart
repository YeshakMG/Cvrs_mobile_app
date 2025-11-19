import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/digitalcertificates_controller.dart';

class DigitalcertificatesView extends GetView<DigitalcertificatesController> {
  const DigitalcertificatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Certificates',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

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
                  ' Certificates',
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

              // Certificates List
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredCertificates.length,
                    itemBuilder: (context, index) {
                      final certificate = controller.filteredCertificates[index];
                      return _buildCertificateCard(certificate);
                    },
                  )),
            ],
          ),
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
        // Certificate image
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
            child: Image.asset(
              certificate.imagePath,
              fit: BoxFit.cover,
            ),
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

  void _downloadCertificate(CertificateService certificate) {
    Get.snackbar(
      'Download Started',
      '${certificate.name} download initiated',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implement actual download functionality
  }

  void _previewCertificate(CertificateService certificate) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                certificate.name,
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.semiBold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                certificate.imagePath,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
