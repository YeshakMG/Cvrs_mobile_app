import 'package:get/get.dart';

import '../controllers/vitalservice_controller.dart';

class VitalserviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VitalserviceController>(
      () => VitalserviceController(),
    );
  }
}
