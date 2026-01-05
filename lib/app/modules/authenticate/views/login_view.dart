import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Determine device type based on screen width
                final isMobile = constraints.maxWidth < 600;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

                // Responsive dimensions
                final horizontalPadding = isMobile ? constraints.maxWidth * 0.07 :
                                      isTablet ? constraints.maxWidth * 0.1 :
                                      constraints.maxWidth * 0.15;

                final verticalPadding = constraints.maxHeight * 0.02;
                final topWelcomePadding = constraints.maxHeight * (isMobile ? 0.12 : 0.08);
                final logoTopPadding = constraints.maxHeight * (isMobile ? 0.03 : 0.02);
                final fieldsTopPadding = constraints.maxHeight * (isMobile ? 0.05 : 0.03);
                final rememberTopPadding = constraints.maxHeight * (isMobile ? 0.03 : 0.02);
                final buttonTopPadding = constraints.maxHeight * (isMobile ? 0.06 : 0.04);
                final guestTopPadding = constraints.maxHeight * (isMobile ? 0.03 : 0.02);

                // Component sizes
                final logoWidth = constraints.maxWidth * (isMobile ? 0.68 : isTablet ? 0.5 : 0.4);
                final logoHeight = constraints.maxHeight * (isMobile ? 0.2 : isTablet ? 0.15 : 0.12);
                final fieldHeight = isMobile ? 50.0 : isTablet ? 55.0 : 60.0;
                final buttonHeight = fieldHeight;

                // Font sizes
                final welcomeFontSize = isMobile ? null : (isTablet ? 24.0 : 28.0);
                final subtitleFontSize = isMobile ? null : (isTablet ? 16.0 : 18.0);

                return Stack(
                  children: [
                    // Language icon positioned at top right
                    Positioned(
                      top: constraints.maxHeight * 0.05,
                      right: horizontalPadding,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: isMobile ? 45 : 50,
                          maxWidth: isMobile ? 80 : 100,
                        ),
                        height: isMobile ? 35 : 40,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 12,
                          vertical: isMobile ? 8 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              color: AppColors.primary,
                              size: isMobile ? 17 : 20,
                            ),
                            SizedBox(width: isMobile ? 5 : 8),
                            Flexible(
                              child: Text(
                                'Eng',
                                style: AppFonts.bodyText2Style.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: AppFonts.medium,
                                  fontSize: isMobile ? null : (isTablet ? 16 : 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Welcome back text
                                Padding(
                                  padding: EdgeInsets.only(top: topWelcomePadding),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Welcome back',
                                      style: AppFonts.headline3Style.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: AppFonts.bold,
                                        fontSize: welcomeFontSize,
                                      ),
                                    ),
                                  ),
                                ),

                                // Hello, sign in to continue text
                                Padding(
                                  padding: EdgeInsets.only(top: verticalPadding),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Hello, sign in to continue',
                                      style: AppFonts.captionStyle.copyWith(
                                        color: AppColors.secondary,
                                        fontSize: subtitleFontSize,
                                      ),
                                    ),
                                  ),
                                ),

                                // Logo image
                                Padding(
                                  padding: EdgeInsets.only(top: logoTopPadding),
                                  child: Image.asset(
                                    'assets/images/logocrrsa.png',
                                    width: logoWidth,
                                    height: logoHeight,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Sign In button
                                Padding(
                                  padding: EdgeInsets.only(top: fieldsTopPadding),
                                  child: _buildLoginButton(buttonHeight, isMobile, isTablet),
                                ),

                                // Continue as Guest text
                                Padding(
                                  padding: EdgeInsets.only(top: guestTopPadding),
                                  child: GestureDetector(
                                    onTap: controller.loginAsGuest,
                                    child: Text(
                                      'Continue as Guest',
                                      style: AppFonts.bodyText2Style.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: AppFonts.medium,
                                        fontSize: isMobile ? null : (isTablet ? 16 : 18),
                                      ),
                                    ),
                                  ),
                                ),

                                // Error message
                                Obx(() => controller.errorMessage.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          controller.errorMessage.value,
                                          style: AppFonts.captionStyle.copyWith(
                                            color: AppColors.error,
                                            fontSize: isMobile ? null : (isTablet ? 14 : 16),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : const SizedBox.shrink()),

                                const Spacer(), // Push content up if needed
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // 🔘 Login button
  Widget _buildLoginButton(double buttonHeight, bool isMobile, bool isTablet) {
    final fontSize = isMobile ? null : (isTablet ? 18.0 : 20.0);
    final indicatorSize = isMobile ? 18.0 : (isTablet ? 20.0 : 22.0);

    return Obx(() => SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: indicatorSize,
                    height: indicatorSize + 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Sign In',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.medium,
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  ),
          ),
        ));
  }
}