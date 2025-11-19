import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../../../../widgets/bottom_navigation.dart';
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
        title: const Text(
          'Settings',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Yeshak Mesfin',
                          style: AppFonts.bodyText1Style.copyWith(
                            fontWeight: AppFonts.regular,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                height: 1,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),

              const SizedBox(height: 20),

              // Menu Items
              _buildMenuItem(
                icon: Icons.info,
                title: 'About Us',
                onTap: () => controller.navigateToAboutUs(),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policies',
                onTap: () => controller.navigateToPrivacyPolicies(),
              ),
              _buildMenuItem(
                icon: Icons.description,
                title: 'Terms and Conditions',
                onTap: () => controller.navigateToTermsAndConditions(),
              ),
              _buildMenuItem(
                icon: Icons.contact_mail,
                title: 'Contact Us',
                onTap: () => controller.navigateToContactUs(),
              ),

              const SizedBox(height: 1),

              // Logout with confirmation
              _buildLogoutMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _showLogoutConfirmationDialog(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodyText1Style.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.redAccent,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodyText1Style.copyWith(
                  color: Colors.redAccent,
                  fontSize: 14,
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
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Get.back(); // Close dialog
              Get.find<SettingsController>().logout(); // Call logout function
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
