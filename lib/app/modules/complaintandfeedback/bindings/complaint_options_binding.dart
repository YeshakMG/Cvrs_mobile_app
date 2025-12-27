import 'package:get/get.dart';

import '../controllers/complaint_options_controller.dart';

class ComplaintOptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintOptionsController>(
      () => ComplaintOptionsController(),
    );
  }
}