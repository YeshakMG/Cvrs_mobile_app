import 'package:get/get.dart';
import '../../../../services/api_service.dart';

class MyComplaintsController extends GetxController {
  var complaints = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  var pageSize = 10.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyComplaints();
  }

  Future<void> fetchMyComplaints({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final response = await ApiService.to.get(
        'citizen-app-service/complaint-service/complaints/my-complaints',
        queryParameters: {
          'page': currentPage.value.toString(),
          'size': pageSize.value.toString(),
        },
      );

      print('My Complaints API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final complaintsData = data['data'];
          if (complaintsData is List) {
            if (loadMore) {
              complaints.addAll(complaintsData.map((e) => e as Map<String, dynamic>));
            } else {
              complaints.value = complaintsData.map((e) => e as Map<String, dynamic>).toList();
            }

            // Check if there are more pages
            hasMore.value = complaintsData.length == pageSize.value;
            if (hasMore.value) {
              currentPage.value++;
            }
          }
        }
      }
    } catch (e) {
      print('My Complaints Error: $e');
      Get.snackbar('Error', 'Failed to load complaints');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (hasMore.value && !isLoading.value) {
      fetchMyComplaints(loadMore: true);
    }
  }
}