import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/constants/colors.dart';
import '../app/constants/fonts.dart';
import '../app/controllers/bottom_navigation_controller.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController controller = Get.find<BottomNavigationController>();
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.fourth,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: AppFonts.bodyText2Style.copyWith(
            color: AppColors.fourth,
            fontWeight: AppFonts.medium,
          ),
          unselectedLabelStyle: AppFonts.captionStyle.copyWith(
            color: Colors.white,
          ),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: controller.selectedIndex.value == 0
                  ? Image.asset('assets/images/homeicon.png', width: 24, height: 20, color: AppColors.fourth)
                  : Image.asset('assets/images/homeicon.png', width: 24, height: 20, color: Colors.white),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.badge),
              label: 'My ID',
            ),
            BottomNavigationBarItem(
              icon: controller.selectedIndex.value == 2
                  ? Image.asset('assets/images/authenticate.png', width: 24, height: 20, color: AppColors.fourth)
                  : Image.asset('assets/images/authenticate.png', width: 24, height: 20, color: Colors.white),
              label: 'Authenticate',
            ),
            BottomNavigationBarItem(
              icon: controller.selectedIndex.value == 3
                  ? Image.asset('assets/images/settingsicon.png', width: 24, height: 20, color: AppColors.fourth)
                  : Image.asset('assets/images/settingsicon.png', width: 24, height: 20, color: Colors.white),
              label: 'Settings',
            ),
          ],
        ));
  }
}