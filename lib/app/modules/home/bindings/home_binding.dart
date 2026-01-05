import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../residentid/controllers/residentid_controller.dart';
import '../../vitalservice/controllers/vitalservice_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.put<ResidentidController>(
      ResidentidController(),
    );
    Get.put<VitalserviceController>(
      VitalserviceController(),
    );
  }
}
