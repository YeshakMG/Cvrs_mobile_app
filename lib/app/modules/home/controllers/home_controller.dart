import 'package:get/get.dart';

class ServiceCategory {
  final String title;
  final String description;
  final String icon;

  ServiceCategory({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class Announcement {
  final String title;
  final String? description;
  final String? imageUrl;

  Announcement({
    required this.title,
    this.description,
    this.imageUrl,
  });
}

class HomeController extends GetxController {
  final count = 0.obs;
  final currentPage = 0.obs;

  // Service categories
  final List<ServiceCategory> serviceCategories = [
    ServiceCategory(
      title: 'Vital',
      description: 'vital category description',
      icon: '🌱',
    ),
    ServiceCategory(
      title: 'Resident',
      description: 'Resident category description',
      icon: '👥',
    ),
    ServiceCategory(
      title: 'Document',
      description: 'Document category description',
      icon: '📄',
    ),
    ServiceCategory(
      title: 'Complain',
      description: 'complain category description',
      icon: '📢',
    ),
  ];

  final announcements = <Announcement>[
    Announcement(
      title: 'New Digital Certificate Service',
      description: 'Apply for digital certificates online',
      imageUrl: 'assets/images/b1.png',
    ),
    Announcement(
      title: 'Vital Records Update',
      description: 'New features for vital records management',
      imageUrl: 'assets/images/b2.png',
    ),
    Announcement(
      title: 'System Maintenance',
      description: 'Scheduled maintenance on Sunday',
      imageUrl: 'assets/images/b3.png',
    ),
  ].obs;

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

  void updateCurrentPage(int index) {
    currentPage.value = index;
  }

  void navigateToNewsDetail(Announcement announcement) {
    // TODO: Navigate to news detail page
    Get.snackbar(
      'News Detail',
      'Navigate to: ${announcement.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectServiceCategory(int index) {
    switch (index) {
      case 0:
        Get.toNamed('/residentid');
        break;
      case 1:
        Get.toNamed('/vitalservice');
        break;
      case 2:
        Get.toNamed('/digitalcertificates');
        break;
      case 3:
        Get.toNamed('/complaintandfeedback');
        break;
    }
  }

  String? _getRouteForCategory(String title) {
    switch (title.toLowerCase()) {
      case 'resident id':
        return '/residentid';
      case 'vital services':
        return '/vitalservice';
      case 'digital certificates':
        return '/digitalcertificates';
      case 'complaint & feedback':
        return '/complaintandfeedback';
      default:
        return null;
    }
  }
}
