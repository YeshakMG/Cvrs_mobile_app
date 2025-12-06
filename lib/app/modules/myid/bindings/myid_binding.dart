import 'package:get/get.dart';

import '../controllers/myid_controller.dart';

class MyidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyidController>(
      () => MyidController(),
    );
  }
}
