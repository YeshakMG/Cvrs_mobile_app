import 'package:get/get.dart';
import '../routes/app_pages.dart';

class BottomNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
    // Add navigation logic here based on the selected tab
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME);
        break;
      case 1:
        Get.offNamed(Routes.MYID);
        break;
      case 2:
        Get.offNamed(Routes.AUTHENTICATE);
        break;
      case 3:
        Get.offNamed(Routes.SETTINGS);
        break;
    }
  }
}