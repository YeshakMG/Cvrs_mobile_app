import 'package:get/get.dart';

import '../controllers/digitalcertificates_controller.dart';

class DigitalcertificatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DigitalcertificatesController>(
      () => DigitalcertificatesController(),
    );
  }
}
