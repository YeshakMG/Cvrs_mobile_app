import 'package:get/get.dart';

import '../../../controllers/bottom_navigation_controller.dart';
import '../controllers/myid_controller.dart';

class MyidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyidController>(
      () => MyidController(),
    );
    Get.lazyPut<BottomNavigationController>(
      () => BottomNavigationController(),
    );
  }
}
