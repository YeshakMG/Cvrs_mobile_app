import 'package:get/get.dart';

import '../controllers/service_detail_controller.dart';

class ServiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceDetailController>(
      () => ServiceDetailController(),
    );
  }
}
