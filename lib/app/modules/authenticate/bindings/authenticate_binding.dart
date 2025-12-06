import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../controllers/authenticate_controller.dart';
import '../controllers/login_controller.dart';

class AuthenticateBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService as a singleton
    Get.put<AuthService>(AuthService(), permanent: true);

    Get.lazyPut<AuthenticateController>(
      () => AuthenticateController(),
    );
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
