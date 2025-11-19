import 'package:get/get.dart';

import '../controllers/complaintandfeedback_controller.dart';

class ComplaintandfeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintandfeedbackController>(
      () => ComplaintandfeedbackController(),
    );
  }
}
