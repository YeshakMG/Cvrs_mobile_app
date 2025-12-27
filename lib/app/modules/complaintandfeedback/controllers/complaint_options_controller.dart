import 'package:get/get.dart';

class ComplaintOptionsController extends GetxController {
  void goToComplaint() {
    Get.toNamed('/complaintandfeedback/complaint-selection');
  }

  void goToMyComplaints() {
    Get.toNamed('/complaintandfeedback/my-complaints');
  }
}