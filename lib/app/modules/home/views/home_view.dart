import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../../../../services/auth_service.dart';
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Determine device type based on screen width
                final isMobile = constraints.maxWidth < 600;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

                // Responsive dimensions
                final horizontalPadding = isMobile ? constraints.maxWidth * 0.05 :
                                      isTablet ? constraints.maxWidth * 0.08 :
                                      constraints.maxWidth * 0.12;
                final verticalPadding = constraints.maxHeight * 0.01;
                final bannerHeight = constraints.maxHeight * 0.22; // 22% as in provided design

                // Fixed spacing: 2 units between all sections
                final sectionSpacing = 2.0; // 2 units between sections

                // Font sizes
                final sectionTitleFontSize = isMobile ? null : (isTablet ? 18.0 : 20.0);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(constraints, isMobile, isTablet),

                      // Announcements Banner
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8.0, // 8 units spacing between header and banner
                        ),
                        child: SizedBox(
                          height: bannerHeight,
                          child: _buildAnnouncementsBanner(),
                        ),
                      ),

                      // Stepper indicator below the banner
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8.0, // 8 units spacing between banner and indicator
                        ),
                        child: _buildStepperIndicator(isMobile, isTablet),
                      ),

                      // "Check Your Status" section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 10.0, // 10 units spacing between stepper and check status
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check Your Status',
                              style: AppFonts.bodyText1Style.copyWith(
                                fontWeight: AppFonts.bold,
                                color: AppColors.primary,
                                fontSize: sectionTitleFontSize,
                              ),
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: isMobile ? 40 : (isTablet ? 50 : 60),
                                maxHeight: isMobile ? 50 : (isTablet ? 60 : 70),
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
                                padding: EdgeInsets.all(isMobile ? 10 : (isTablet ? 12 : 15)),
                                child: _buildCheckStatusSection(isMobile, isTablet),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spacing between check status and service categories
                      SizedBox(height: sectionSpacing),

                      // Service Categories - Fixed height to allow scrolling
                      SizedBox(
                        height: constraints.maxHeight * 0.5, // Adjust height as needed
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: 30.0, // 30 units spacing between check status and service categories
                            bottom: sectionSpacing,
                          ),
                          child: _buildServiceCategories(constraints, isMobile, isTablet),
                        ),
                      ),

                      // Minimal bottom spacing for navigation
                      SizedBox(height: isMobile ? 20 : (isTablet ? 30 : 40)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildHeader(BoxConstraints constraints, bool isMobile, bool isTablet) {
    final authService = AuthService.to;
    final userName = authService.currentUser['name'] ?? authService.currentUser['preferred_username'] ?? 'User';

    final headerHeight = isMobile ? 50.0 : (isTablet ? 55.0 : 60.0);
    final horizontalPadding = isMobile ? 14.0 : (isTablet ? 18.0 : 24.0);
    final iconSize = isMobile ? 18.0 : (isTablet ? 20.0 : 22.0);
    final fontSize = isMobile ? null : (isTablet ? 16.0 : 18.0);

    return Container(
      width: double.infinity,
      height: headerHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Stack(
        children: [
          // Welcome user text positioned at top left
          Positioned(
            top: isMobile ? 20 : (isTablet ? 24 : 28),
            left: isMobile ? 15 : (isTablet ? 18 : 24),
            right: isMobile ? 120 : (isTablet ? 140 : 160), // Leave space for icons on the right
            child: SizedBox(
              height: isMobile ? 20 : (isTablet ? 24 : 28),
              child: Text(
                'Welcome, $userName',
                style: AppFonts.bodyText1Style.copyWith(
                  fontWeight: AppFonts.medium,
                  color: AppColors.primary,
                  fontSize: fontSize,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

          // Notification icon positioned at specified location
          Positioned(
            top: isMobile ? 20 : (isTablet ? 24 : 28),
            right: isMobile ? 50 : (isTablet ? 60 : 70),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: iconSize,
                ),
                onPressed: () {
                  Get.snackbar('Notifications', 'Coming soon!');
                },
              ),
            ),
          ),

          // Language selector positioned at specified location
          Positioned(
            top: isMobile ? 10 : (isTablet ? 12 : 16),
            right: 0,
            child: SizedBox(
              width: isMobile ? 45 : (isTablet ? 50 : 55),
              height: isMobile ? 35 : (isTablet ? 40 : 45),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 10 : (isTablet ? 12 : 14)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: iconSize,
                    ),
                    SizedBox(width: isMobile ? 5 : 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories(BoxConstraints constraints, bool isMobile, bool isTablet) {
    final crossAxisCount = isTablet ? 3 : (constraints.maxWidth >= 1200 ? 4 : 2);
    final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final topSpacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

    final services = [
      {
        'icon': Icons.person,
        'title': 'Resident Services',
        'description': 'Manage your personal identification documents',
        'onTap': () => controller.selectServiceCategory(0),
      },
      {
        'icon': Icons.book,
        'title': 'Vital Services',
        'description': 'Access vital records and certificates',
        'onTap': () => controller.selectServiceCategory(1),
      },
      {
        'icon': Icons.description,
        'title': 'Digital Certificates',
        'description': 'Download and verify digital documents',
        'onTap': () => controller.selectServiceCategory(2),
      },
      {
        'icon': Icons.feedback,
        'title': 'Complaint & Feedback',
        'description': 'Submit complaints and provide feedback',
        'onTap': () => controller.selectServiceCategory(3),
      },
    ];

    if (!isMobile) {
      // Grid layout for tablets and desktop
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isTablet ? 1.2 : 1.1,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _serviceCard(
            service['icon'] as IconData,
            service['title'] as String,
            service['description'] as String,
            service['onTap'] as VoidCallback,
            isMobile,
            isTablet,
          );
        },
      );
    } else {
      // Row layout for phones
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          // First row
          Row(
            children: [
              Expanded(child: _serviceCard(
                services[0]['icon'] as IconData,
                services[0]['title'] as String,
                services[0]['description'] as String,
                services[0]['onTap'] as VoidCallback,
                isMobile,
                isTablet,
              )),
              SizedBox(width: spacing),
              Expanded(child: _serviceCard(
                services[1]['icon'] as IconData,
                services[1]['title'] as String,
                services[1]['description'] as String,
                services[1]['onTap'] as VoidCallback,
                isMobile,
                isTablet,
              )),
            ],
          ),
          SizedBox(height: spacing * 2), // Double the spacing to prevent overlap
          // Second row
          Row(
            children: [
              Expanded(child: _serviceCard(
                services[2]['icon'] as IconData,
                services[2]['title'] as String,
                services[2]['description'] as String,
                services[2]['onTap'] as VoidCallback,
                isMobile,
                isTablet,
              )),
              SizedBox(width: spacing),
              Expanded(child: _serviceCard(
                services[3]['icon'] as IconData,
                services[3]['title'] as String,
                services[3]['description'] as String,
                services[3]['onTap'] as VoidCallback,
                isMobile,
                isTablet,
              )),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildAnnouncementsBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerHeight = constraints.maxHeight;
        final bannerWidth = constraints.maxWidth;

        return CarouselSlider.builder(
          itemCount: controller.announcements.length,
          itemBuilder: (context, index, realIndex) {
            final announcement = controller.announcements[index];
            return GestureDetector(
              onTap: () => controller.navigateToNewsDetail(announcement),
              child: Container(
                width: bannerWidth,
                height: bannerHeight,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            height: bannerHeight,
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
      },
    );
  }

  Widget _buildStepperIndicator(bool isMobile, bool isTablet) {
    final indicatorWidth = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
    final indicatorHeight = isMobile ? 4.0 : (isTablet ? 5.0 : 6.0);
    final margin = isMobile ? 2.0 : (isTablet ? 3.0 : 4.0);

    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.announcements.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: indicatorWidth,
          height: indicatorHeight,
          margin: EdgeInsets.symmetric(horizontal: margin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(indicatorHeight / 2),
            color: index == controller.currentPage.value
                ? AppColors.primary
                : Colors.grey[300],
          ),
        ),
      ),
    ));
  }

  Widget _buildCheckStatusSection(bool isMobile, bool isTablet) {
    final fieldHeight = isMobile ? 36.0 : (isTablet ? 40.0 : 44.0);
    final buttonSize = isMobile ? 40.0 : (isTablet ? 44.0 : 48.0);
    final iconSize = isMobile ? 28.0 : (isTablet ? 30.0 : 32.0);
    final fontSize = isMobile ? null : (isTablet ? 14.0 : 16.0);
    final spacing = isMobile ? 1.0 : 2.0;

    return Container(
      width: double.infinity,
      height: fieldHeight,
      padding: EdgeInsets.only(
        left: isMobile ? 10 : (isTablet ? 12 : 15),
        right: isMobile ? 15 : (isTablet ? 18 : 20),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(isMobile ? 6 : (isTablet ? 8 : 10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorHeight: 10.0,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Enter Code',
                labelStyle: AppFonts.captionStyle.copyWith(
                  fontWeight: AppFonts.medium,
                  color: AppColors.tertiary,
                  fontSize: fontSize,
                ),
                hintText: 'MB XXXXXXXX ET',
                hintStyle: AppFonts.bodyText2Style.copyWith(
                  color: Colors.black54,
                  fontSize: 10.0,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            width: buttonSize,
            height: buttonSize,
            margin: EdgeInsets.only(left: isMobile ? 8 : (isTablet ? 10 : 12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(buttonSize / 2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.search,
                color: AppColors.primary,
                size: iconSize,
              ),
              onPressed: () {
                // Handle check status action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, String description, VoidCallback onTap, bool isMobile, bool isTablet) {
    final iconSize = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final iconContainerSize = isMobile ? 40.0 : (isTablet ? 48.0 : 56.0);
    final padding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final margin = isMobile ? 5.0 : (isTablet ? 6.0 : 8.0);
    final titlePadding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final spacing = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final minHeight = isMobile ? 140.0 : (isTablet ? 160.0 : 180.0);
    final fontSize = isMobile ? null : (isTablet ? 14.0 : 16.0);
    final descriptionFontSize = isMobile ? null : (isTablet ? 12.0 : 14.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
          maxHeight: double.infinity,
        ),
        margin: EdgeInsets.symmetric(horizontal: margin),
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
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: iconContainerSize), // Space for icon
                  // Title
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: titlePadding, vertical: 4),
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
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(height: spacing),
                  // Description
                  Text(
                    description,
                    style: AppFonts.overlineStyle.copyWith(
                      color: Colors.grey[600],
                      height: 1.3,
                      fontSize: descriptionFontSize,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
              // Icon positioned at top left
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: iconSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
