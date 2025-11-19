import 'package:get/get.dart';

class CertificateService {
  final String name;
  final String imagePath;
  final String type;

  CertificateService({
    required this.name,
    required this.imagePath,
    required this.type,
  });
}

class DigitalcertificatesController extends GetxController {
  final count = 0.obs;
  final selectedServiceType = 'All'.obs;
  final serviceTypes = ['All', 'Vital', 'Resident'].obs;

  final certificates = <CertificateService>[
    CertificateService(
      name: 'Birth Certificate',
      imagePath: 'assets/images/death_certificate.png',
      type: 'Vital',
    ),
    CertificateService(
      name: 'Death Certificate',
      imagePath: 'assets/images/death_certificate.png',
      type: 'Vital',
    ),
    CertificateService(
      name: 'Marriage Certificate',
      imagePath: 'assets/images/death_certificate.png',
      type: 'Vital',
    ),
    CertificateService(
      name: 'Resident ID',
      imagePath: 'assets/images/death_certificate.png',
      type: 'Resident',
    ),
    CertificateService(
      name: 'Address Certificate',
      imagePath: 'assets/images/death_certificate.png',
      type: 'Resident',
    ),
  ].obs;

  List<CertificateService> get filteredCertificates {
    if (selectedServiceType.value == 'All') {
      return certificates;
    }
    return certificates.where((cert) => cert.type == selectedServiceType.value).toList();
  }
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
