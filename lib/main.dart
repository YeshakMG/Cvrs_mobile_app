import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'app/constants/colors.dart';
import 'app/constants/fonts.dart';
import 'app/controllers/bottom_navigation_controller.dart';
import 'app/routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';

void main() async {
  // Configure logging to reduce startup noise
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      level: record.level.value,
      name: record.loggerName,
    );
  });

  // Initialize services
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<BottomNavigationController>(BottomNavigationController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CRRSA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
        ),
        fontFamily: AppFonts.primaryFont,
        textTheme: TextTheme(
          headlineLarge: AppFonts.headline1Style,
          headlineMedium: AppFonts.headline2Style,
          headlineSmall: AppFonts.headline3Style,
          titleLarge: AppFonts.headline4Style,
          titleMedium: AppFonts.headline5Style,
          titleSmall: AppFonts.headline6Style,
          bodyLarge: AppFonts.bodyText1Style,
          bodyMedium: AppFonts.bodyText2Style,
          bodySmall: AppFonts.captionStyle,
          labelSmall: AppFonts.overlineStyle,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.fourth,
          unselectedItemColor: Colors.white70,
        ),
      ),
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
    );
  }
}

