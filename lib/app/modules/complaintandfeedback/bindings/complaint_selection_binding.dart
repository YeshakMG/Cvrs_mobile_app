import 'package:get/get.dart';

import '../controllers/complaint_selection_controller.dart';

class ComplaintSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintSelectionController>(
      () => ComplaintSelectionController(),
    );
  }
}