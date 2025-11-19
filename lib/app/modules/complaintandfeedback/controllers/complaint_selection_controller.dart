import 'package:get/get.dart';

class ComplaintSelectionController extends GetxController {
  //TODO: Implement ComplaintSelectionController

  final count = 0.obs;

  void selectComplaintType(String type) {
    if (type == 'service') {
      Get.toNamed('/complaintandfeedback/complaint-selection/service-complaint');
    } else {
      Get.toNamed('/complaintandfeedback/complaint-selection/expert-complaint');
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}