import 'package:get/get.dart';

import '../controllers/expert_complaint_controller.dart';

class ExpertComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertComplaintController>(
      () => ExpertComplaintController(),
    );
  }
}