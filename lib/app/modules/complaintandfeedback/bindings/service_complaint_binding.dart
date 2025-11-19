import 'package:get/get.dart';

import '../controllers/service_complaint_controller.dart';

class ServiceComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceComplaintController>(
      () => ServiceComplaintController(),
    );
  }
}