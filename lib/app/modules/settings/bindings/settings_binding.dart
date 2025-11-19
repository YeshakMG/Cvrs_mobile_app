import 'package:get/get.dart';

import '../../../controllers/bottom_navigation_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
    Get.lazyPut<BottomNavigationController>(
      () => BottomNavigationController(),
    );
  }
}
