import 'package:get/get.dart';

import '../../../../widgets/bottom_navigation.dart';
import '../../../controllers/bottom_navigation_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<BottomNavigationController>(
      () => BottomNavigationController(),
    );
  }
}
