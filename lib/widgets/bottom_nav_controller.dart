import 'package:get/get.dart';
import '../app/routes/app_pages.dart';

class BottomNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
    // Add navigation logic here based on the selected tab
    switch (index) {
      case 0:
        Get.toNamed(Routes.HOME);
        break;
      case 1:
        Get.toNamed(Routes.MYID);
        break;
      case 2:
        Get.toNamed(Routes.AUTHENTICATE);
        break;
      case 3:
        Get.toNamed(Routes.SETTINGS);
        break;
    }
  }
}