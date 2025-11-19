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
      body: Stack(
        children: [
          // Language icon positioned at top right
          Positioned(
            top: 53,
            right: 27, // 366px from left on a typical screen width, so right: 27px
            child: Container(
              constraints: const BoxConstraints(minWidth: 45, maxWidth: 80),
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    color: AppColors.primary,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Eng',
                      style: AppFonts.bodyText2Style.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome back text
                Padding(
                  padding: const EdgeInsets.only(top: 106, left: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome back',
                      style: AppFonts.headline3Style.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ),
                ),

                // Hello, sign in to continue text
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hello, sign in to continue',
                      style: AppFonts.captionStyle.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),

                // Logo image
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Image.asset(
                    'assets/images/logocrrsa.png',
                    width: 255,
                    height: 199,
                    fit: BoxFit.contain,
                  ),
                ),

                // Phone number and password fields
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 27, right: 27),
                  child: Column(
                    children: [
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                    ],
                  ),
                ),

                // Remember me and Forgot password
                Padding(
                  padding: const EdgeInsets.only(top: 28, left: 27, right: 27),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Obx(() => Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: controller.toggleRememberMe,
                              )),
                          Text(
                            'Remember Me',
                            style: AppFonts.bodyText2Style.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: controller.forgotPassword,
                        child: Text(
                          'Forget Password?',
                          style: AppFonts.bodyText2Style.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign In button
                Padding(
                  padding: const EdgeInsets.only(top: 57, left: 27, right: 27),
                  child: _buildLoginButton(),
                ),

                // Skip Now text
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 50),
                  child: Text(
                    'Continue as Guest',
                    style: AppFonts.bodyText2Style.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ),

                Obx(() => controller.errorMessage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppFonts.captionStyle.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📱 Phone field
  Widget _buildPhoneField() {
    return Container(
      width: 386.2140197753906,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: ''),
        onChanged: controller.updateEmail,
        decoration: InputDecoration(
          labelText: 'Phone number',
          labelStyle: AppFonts.captionStyle.copyWith(
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 13, left: 50, bottom: 13, right: 19),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 19, top: 13, bottom: 13),
            child: Icon(
              Icons.phone,
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // 🔒 Password field
  Widget _buildPasswordField() {
    return Container(
      width: 386.2140197753906,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: ''),
        onChanged: controller.updatePassword,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: AppFonts.captionStyle.copyWith(
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 16.5, left: 50, bottom: 16.5, right: 50),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 19, top: 16.5, bottom: 16.5),
            child: Icon(
              Icons.lock,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 19),
            child: Icon(
              Icons.visibility,
              size: 20.691951751708984,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 Login button
  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Sign In',
                    style: AppFonts.bodyText1Style.copyWith(
                      fontWeight: AppFonts.medium,
                      color: Colors.white,
                    ),
                  ),
          ),
        ));
  }
}