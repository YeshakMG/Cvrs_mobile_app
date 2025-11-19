import 'package:get/get.dart';

class ComplaintandfeedbackController extends GetxController {
  //TODO: Implement ComplaintandfeedbackController

  final count = 0.obs;

  void selectOption(String option) {
    if (option == 'complaint') {
      Get.toNamed('/complaintandfeedback/complaint-selection');
    } else if (option == 'feedback') {
      Get.toNamed('/complaintandfeedback/feedback');
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
