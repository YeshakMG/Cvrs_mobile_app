import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../routes/app_pages.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/authenticate_controller.dart';

class CertificateIdController extends TextEditingController {
  final AuthenticateController controller;

  CertificateIdController(this.controller) {
    addListener(() {
      controller.certificateId.value = text;
    });
  }
}

class AuthenticateView extends GetView<AuthenticateController> {
  const AuthenticateView({super.key});

  @override
  Widget build(BuildContext context) {
    final certificateController = CertificateIdController(controller);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'Authentication',
              style: AppFonts.headline6Style.copyWith(
                color: Colors.white,
                fontWeight: AppFonts.regular,
                fontSize: fontSize,
              ),
            );
          },
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine device type based on screen width
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

            // Responsive dimensions
            final padding = isMobile ? 16.0 : (isTablet ? 32.0 : 48.0);
            final maxWidth = isMobile ? double.infinity :
                            isTablet ? constraints.maxWidth * 0.7 :
                            constraints.maxWidth * 0.5;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      const SizedBox(height: 20),


                      const SizedBox(height: 12),
                      Text(
                        'Enter certificate ID or scan QR code to authenticate',
                        style: AppFonts.bodyText2Style.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Certificate ID Input with QR Scanner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            TextField(
                              controller: certificateController,
                              decoration: InputDecoration(
                                hintText: 'Enter certificate ID',
                                hintStyle: const TextStyle(fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  onPressed: controller.scanQRCode,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Authenticate Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.certificateId.value.isEmpty
                                  ? null
                                  : controller.authenticateCertificate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Authenticate',
                                style: AppFonts.bodyText1Style.copyWith(
                                  fontWeight: AppFonts.regular,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 40),

                      // Authentication Result
                      Obx(() => controller.isAuthenticated.value
                            ? Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Icon(Icons.check_circle, color: Colors.green[700]),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Authenticated Successfully',
                                              style: AppFonts.headline6Style.copyWith(
                                                color: Colors.green[700],
                                                fontWeight: AppFonts.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Text(
                                      //   'Certificate Authentication Justification:',
                                      //   style: AppFonts.bodyText1Style.copyWith(
                                      //     fontWeight: AppFonts.medium,
                                      //     color: AppColors.textPrimary,
                                      //   ),
                                      // ),
                                      const SizedBox(height: 8),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Your request for autehtication with Id  ',
                                              style: AppFonts.bodyText2Style.copyWith(
                                                color: AppColors.textSecondary,
                                                height: 1.4,
                                              ),
                                            ),
                                            TextSpan(
                                              text: controller.certificateId.value,
                                              style: AppFonts.bodyText2Style.copyWith(
                                                color: AppColors.primary,
                                                height: 1.4,
                                                fontWeight: AppFonts.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' is authenticated.',
                                              style: AppFonts.bodyText2Style.copyWith(
                                                color: AppColors.primary,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.green[200]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Text(
                                            //   'Certificate Details:',
                                            //   style: AppFonts.bodyText1Style.copyWith(
                                            //     fontWeight: AppFonts.medium,
                                            //     color: AppColors.textPrimary,
                                            //   ),
                                            // ),
                                            const SizedBox(height: 12),
                                            _buildDetailRow('Registration No', controller.authenticatedUser.value?.certificateNo ?? ''),
                                            _buildDetailRow('Full Name', controller.authenticatedUser.value?.fullName ?? ''),
                                            _buildDetailRow('Date of Birth', controller.authenticatedUser.value?.dateOfBirth ?? ''),
                                            _buildDetailRow('Address', controller.authenticatedUser.value?.address ?? ''),
                                            _buildDetailRow('Phone No', controller.authenticatedUser.value?.phoneNo ?? ''),
                                            _buildDetailRow('Nationality', controller.authenticatedUser.value?.nationality ?? ''),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),

                      // Loading indicator
                      Obx(() => controller.isLoading.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF073C59)),
                            )
                          : const SizedBox.shrink()),
                        ],
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppFonts.bodyText2Style.copyWith(
                fontWeight: AppFonts.medium,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyText2Style.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

 

}

