import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/my_complaints_controller.dart';

class MyComplaintsView extends GetView<MyComplaintsController> {
  const MyComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Complaints',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
            final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);

            return Obx(() {
              if (controller.isLoading.value && controller.complaints.isEmpty) {
                return _buildShimmerList(isMobile, isTablet);
              }

              if (controller.complaints.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: isMobile ? 64 : (isTablet ? 80 : 96),
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'No complaints found',
                        style: AppFonts.bodyText1Style.copyWith(
                          color: AppColors.primary,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.currentPage.value = 1;
                  controller.hasMore.value = true;
                  await controller.fetchMyComplaints();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(padding),
                  itemCount: controller.complaints.length + (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.complaints.length) {
                      // Load more indicator
                      controller.loadMore();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final complaint = controller.complaints[index];
                    return _buildComplaintCard(complaint, isMobile, isTablet, spacing, cardPadding, fontSize);
                  },
                ),
              );
            });
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint, bool isMobile, bool isTablet, double spacing, double cardPadding, double fontSize) {
    final type = complaint['type'] ?? 'Unknown';
    final description = complaint['description'] ?? '';
    final status = complaint['status'] ?? 'Unknown';
    final createdAt = complaint['createdAt'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: spacing),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  type == 'SERVICE' ? Icons.miscellaneous_services : Icons.person,
                  color: AppColors.primary,
                  size: isMobile ? 24 : (isTablet ? 28 : 32),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    type == 'SERVICE' ? 'Service Complaint' : 'Expert Complaint',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.semiBold,
                      color: AppColors.primary,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: spacing * 0.5, vertical: spacing * 0.25),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Text(
              description,
              style: AppFonts.bodyText2Style.copyWith(
                color: AppColors.textPrimary,
                fontSize: fontSize * 0.9,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing * 0.5),
            Text(
              'Created: ${createdAt.isNotEmpty ? createdAt : 'Unknown'}',
              style: AppFonts.bodyText2Style.copyWith(
                color: AppColors.textSecondary,
                fontSize: fontSize * 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildShimmerList(bool isMobile, bool isTablet) {
    final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16.0 : (isTablet ? 24.0 : 32.0)),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: spacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isMobile ? 24 : (isTablet ? 28 : 32),
                        height: isMobile ? 24 : (isTablet ? 28 : 32),
                        color: Colors.grey,
                      ),
                      SizedBox(width: spacing),
                      Container(
                        width: 120,
                        height: isMobile ? 16 : (isTablet ? 18 : 20),
                        color: Colors.grey,
                      ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: isMobile ? 20 : (isTablet ? 22 : 24),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  Container(
                    width: double.infinity,
                    height: isMobile ? 14 : (isTablet ? 16 : 18),
                    color: Colors.grey,
                  ),
                  SizedBox(height: spacing * 0.5),
                  Container(
                    width: 100,
                    height: isMobile ? 12 : (isTablet ? 14 : 16),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}