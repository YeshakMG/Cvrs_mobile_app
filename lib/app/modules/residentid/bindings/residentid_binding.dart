import 'package:get/get.dart';

import '../controllers/residentid_controller.dart';

class ResidentidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResidentidController>(
      () => ResidentidController(),
    );
  }
}
