import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../../../../services/auth_service.dart';
import '../../../controllers/bottom_navigation_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavController = Get.find<BottomNavigationController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to Home
            bottomNavController.changeTab(0);
            Get.offNamed('/home');
          },
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            final fontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            return Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            );
          },
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

            // Responsive dimensions
            final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
            final avatarRadius = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);
            final avatarIconSize = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);
            final spacing = isMobile ? 20.0 : (isTablet ? 25.0 : 30.0);
            final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing),

                  // Profile Section
                  Obx(() {
                    final authService = AuthService.to;
                    final userName = authService.currentUser.value['name'] ?? authService.currentUser.value['preferred_username'] ?? 'User';

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: avatarIconSize,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: isMobile ? 16 : 20),
                            Expanded(
                              child: Text(
                                userName,
                                style: AppFonts.bodyText1Style.copyWith(
                                  fontWeight: AppFonts.regular,
                                  color: AppColors.primary,
                                  fontSize: isMobile ? null : (isTablet ? 16.0 : 18.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: spacing * 1.5),

                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: EdgeInsets.symmetric(vertical: isMobile ? 10 : 15),
                  ),

                  SizedBox(height: spacing),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () => controller.navigateToAboutUs(),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policies',
                    onTap: () => controller.navigateToPrivacyPolicies(),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Terms and Conditions',
                    onTap: () => controller.navigateToTermsAndConditions(),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  _buildMenuItem(
                    icon: Icons.contact_mail,
                    title: 'Contact Us',
                    onTap: () => controller.navigateToContactUs(),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),

                  SizedBox(height: isMobile ? 1 : 2),

                  // Logout with confirmation
                  _buildLogoutMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () => _showLogoutConfirmationDialog(context),
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isTablet,
  }) {
    final iconSize = isMobile ? 24.0 : (isTablet ? 26.0 : 28.0);
    final arrowSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final padding = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    final spacing = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodyText1Style.copyWith(
                  color: AppColors.primary,
                  fontSize: fontSize,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: arrowSize,
            ),
          ],
        ),
      ),
    );
  }

  // Logout Item (no arrow)
  Widget _buildLogoutMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isTablet,
  }) {
    final iconSize = isMobile ? 24.0 : (isTablet ? 26.0 : 28.0);
    final fontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final padding = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    final spacing = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.redAccent,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodyText1Style.copyWith(
                  color: Colors.redAccent,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Confirmation dialog for logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Clear user data and navigate to login
                AuthService.to.logout();
                Get.offAllNamed('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
