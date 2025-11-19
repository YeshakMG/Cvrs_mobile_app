import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../routes/app_pages.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Constants for better maintainability
  static const double kBannerHeight = 216.0;
  static const double kBannerWidth = 408.38;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Header Section with positioned elements
            _buildHeader(),

            // Announcements Banner positioned at specified layout
            Positioned(
              top: 70,
              left: 20,
              right: 20, // Add right constraint to prevent overflow
              child: SizedBox(
                height: kBannerHeight,
                child: _buildAnnouncementsBanner(),
              ),
            ),

            // Stepper indicator below the banner
            Positioned(
              top: 300, // Adjusted for new banner position
              left: 16,
              right: 16,
              child: _buildStepperIndicator(),
            ),

            // "Check Your Status" title above the card
            Positioned(
              top: 330,
              left: 20,
              right: 20,
              child: Text(
                'Check Your Status',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Check Your Status card (contains only Enter Code and input field)
            Positioned(
              top: 365, // Adjusted for new title position
              left: 20,
              right: 20,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 60, // Minimum height
                  maxHeight: 80, // Maximum height to prevent overflow
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildCheckStatusSection(),
                ),
              ),
            ),

            // Service Categories positioned below Check Your Status
            Positioned(
              top: 460, // Adjusted for new card position
              left: 20,
              right: 20,
              child: _buildServiceCategories(),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 650, left: 16.0, right: 16.0, bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add bottom spacing to ensure content doesn't overlap with navigation
                  const SizedBox(height: 50),
                ],
              ),
            ),

            // Bottom Navigation Bar positioned at the bottom, overlaying content

          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 60, // Reduced height for header
      padding: const EdgeInsets.symmetric(horizontal: 14), // Add horizontal padding
      child: Stack(
        children: [
          // Welcome Yeshak Mesfin text positioned at top left
          Positioned(
            top: 20,
            left: 15, // Position from container start
            right: 120, // Leave space for icons on the right
            child: SizedBox(
              height: 20,
              child: Text(
                'Welcome, Yeshak Mesfin',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.medium,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis, // Handle text overflow
                maxLines: 1,
              ),
            ),
          ),

          // Notification icon positioned at specified location
          Positioned(
            top: 20,
            right: 50, // Position from right edge
            child: SizedBox(
              width: 18,
              height: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Remove default constraints
                icon: Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () {
                  Get.snackbar('Notifications', 'Coming soon!');
                },
              ),
            ),
          ),

          // Language selector positioned at specified location
          Positioned(
            top: 10, // Adjusted for smaller header
            right: 0, // Position from right edge
            child: SizedBox(
              width: 45,
              height: 35,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    // Text(
                    //   'En',
                    //   style: TextStyle(
                    //     fontFamily: 'Montserrat',
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w500,
                    //     color: const Color(0xFF073C59),
                    //     ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // First row of service cards
        Row(
          children: [
            Expanded(child: _serviceCard(
              Icons.person,
              'Resident Services',
              'Manage your personal identification documents',
              () => controller.selectServiceCategory(0),
            )),
            const SizedBox(width: 12),
            Expanded(child: _serviceCard(
              Icons.book,
              'Vital Services',
              'Access vital records and certificates',
              () => controller.selectServiceCategory(1),
            )),
          ],
        ),
        const SizedBox(height: 16),

        // Second row of service cards
        Row(
          children: [
            Expanded(child: _serviceCard(
              Icons.description,
              'Digital Certificates',
              'Download and verify digital documents',
              () => controller.selectServiceCategory(2),
            )),
            const SizedBox(width: 12),
            Expanded(child: _serviceCard(
              Icons.feedback,
              'Complaint & Feedback',
              'Submit complaints and provide feedback',
              () => controller.selectServiceCategory(3),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnouncementsBanner() {
    return CarouselSlider.builder(
      itemCount: controller.announcements.length,
      itemBuilder: (context, index, realIndex) {
        final announcement = controller.announcements[index];
        return GestureDetector(
          onTap: () => controller.navigateToNewsDetail(announcement),
          child: Container(
            width: kBannerWidth,
            height: kBannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: announcement.imageUrl != null
                    ? AssetImage(announcement.imageUrl!)
                    : const AssetImage("assets/images/news.jpg"),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading errors gracefully
                  debugPrint('Error loading image: $exception');
                },
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: AppFonts.bodyText1Style.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  if (announcement.description?.isNotEmpty ?? false)
                    Text(
                      announcement.description!,
                      style: AppFonts.captionStyle.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: kBannerHeight,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0, // Full width within container
        onPageChanged: (index, reason) {
          // Update stepper indicator when page changes
          controller.updateCurrentPage(index);
        },
      ),
    );
  }

  Widget _buildStepperIndicator() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.announcements.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24, // Increased width for stretched rectangle
          height: 4, // Reduced height for thin rectangle
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2), // Small border radius for rectangle
            color: index == controller.currentPage.value
                ? AppColors.primary
                : Colors.grey[300],
          ),
        ),
      ),
    ));
  }

  Widget _buildCheckStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Enter Code" text above input field
        Text(
          'Enter Code',
          style: AppFonts.captionStyle.copyWith(
            fontWeight: AppFonts.medium,
            color: AppColors.tertiary,
          ),
        ),
        const SizedBox(height: 1),

        // Text field with trailing icon (full width)
        Container(
          width: double.infinity,

          height: 36, // Reduced height
          padding: const EdgeInsets.only(left: 10, right: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(6), // Smaller radius
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'MB XXXXXXXX ET',
                    hintStyle: AppFonts.bodyText2Style.copyWith(
                      color: Colors.black54,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
                  ),
                ),
              ),
              Container(
                width: 40, // 40px width
                height: 40, // 40px height
                margin: const EdgeInsets.only(left: 8), // Move to the right
                decoration: BoxDecoration(
                  color: Colors.white, // Gray background
                  borderRadius: BorderRadius.circular(100), // 100px border radius for full circle
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 28, // Adjusted icon size for larger button
                  ),
                  onPressed: () {
                    // Handle check status action
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(IconData icon, String title, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 140, // Minimum height
          maxHeight: double.infinity, // Allow dynamic height
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Space for icon
                  // Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      title,
                      style: AppFonts.captionStyle.copyWith(
                        fontWeight: AppFonts.semiBold,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    style: AppFonts.overlineStyle.copyWith(
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 10, // Allow more lines
                    overflow: TextOverflow.visible, // Show all text
                  ),
                ],
              ),
              // Icon positioned at top left
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
