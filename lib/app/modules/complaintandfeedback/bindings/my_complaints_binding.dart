import 'package:get/get.dart';

import '../controllers/my_complaints_controller.dart';

class MyComplaintsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyComplaintsController>(
      () => MyComplaintsController(),
    );
  }
}