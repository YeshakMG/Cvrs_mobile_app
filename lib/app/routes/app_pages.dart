import 'package:get/get.dart';

import '../modules/authenticate/bindings/authenticate_binding.dart';
import '../modules/authenticate/views/authenticate_view.dart';
import '../modules/authenticate/views/login_view.dart' as auth_login;
import '../modules/complaintandfeedback/bindings/complaintandfeedback_binding.dart';
import '../modules/complaintandfeedback/views/complaintandfeedback_view.dart';
import '../modules/complaintandfeedback/bindings/complaint_selection_binding.dart';
import '../modules/complaintandfeedback/views/complaint_selection_view.dart';
import '../modules/complaintandfeedback/bindings/service_complaint_binding.dart';
import '../modules/complaintandfeedback/views/service_complaint_view.dart';
import '../modules/complaintandfeedback/bindings/expert_complaint_binding.dart';
import '../modules/complaintandfeedback/views/expert_complaint_view.dart';
import '../modules/complaintandfeedback/bindings/feedback_binding.dart';
import '../modules/complaintandfeedback/views/feedback_view.dart';
import '../modules/complaintandfeedback/bindings/qr_scanner_binding.dart';
import '../modules/complaintandfeedback/views/qr_scanner_view.dart';
import '../modules/digitalcertificates/bindings/digitalcertificates_binding.dart';
import '../modules/digitalcertificates/views/digitalcertificates_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/myid/bindings/myid_binding.dart';
import '../modules/myid/views/myid_view.dart';
import '../modules/residentid/bindings/residentid_binding.dart';
import '../modules/residentid/service_detail/bindings/service_detail_binding.dart';
import '../modules/residentid/service_detail/views/service_detail_view.dart';
import '../modules/residentid/views/residentid_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/vitalservice/bindings/vitalservice_binding.dart';
import '../modules/vitalservice/views/vitalservice_view.dart';
import '../modules/vitalservice/service_detail/bindings/service_detail_binding.dart' as vital_service_detail_binding;
import '../modules/vitalservice/service_detail/views/service_detail_view.dart' as vital_service_detail_view;
import '../modules/vitalservice/service_detail/bindings/service_detail_binding.dart' as vital_service_detail_binding;
import '../modules/vitalservice/service_detail/views/service_detail_view.dart' as vital_service_detail_view;

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const auth_login.LoginView(),
      binding: AuthenticateBinding(),
    ),
    GetPage(
      name: _Paths.MYID,
      page: () => const MyidView(),
      binding: MyidBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATE,
      page: () => const AuthenticateView(),
      binding: AuthenticateBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.RESIDENTID,
      page: () => const ResidentidView(),
      binding: ResidentidBinding(),
      children: [
        GetPage(
          name: _Paths.SERVICE_DETAIL,
          page: () => const ServiceDetailView(),
          binding: ServiceDetailBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.VITALSERVICE,
      page: () => const VitalserviceView(),
      binding: VitalserviceBinding(),
      children: [
        GetPage(
          name: _Paths.SERVICE_DETAIL,
          page: () => const vital_service_detail_view.ServiceDetailView(),
          binding: vital_service_detail_binding.ServiceDetailBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.DIGITALCERTIFICATES,
      page: () => const DigitalcertificatesView(),
      binding: DigitalcertificatesBinding(),
    ),
    GetPage(
      name: _Paths.COMPLAINTANDFEEDBACK,
      page: () => const ComplaintandfeedbackView(),
      binding: ComplaintandfeedbackBinding(),
      children: [
        GetPage(
          name: _Paths.COMPLAINT_SELECTION,
          page: () => const ComplaintSelectionView(),
          binding: ComplaintSelectionBinding(),
          children: [
            GetPage(
              name: _Paths.SERVICE_COMPLAINT,
              page: () => const ServiceComplaintView(),
              binding: ServiceComplaintBinding(),
            ),
            GetPage(
              name: _Paths.EXPERT_COMPLAINT,
              page: () => const ExpertComplaintView(),
              binding: ExpertComplaintBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.FEEDBACK,
          page: () => const FeedbackView(),
          binding: FeedbackBinding(),
        ),
        GetPage(
          name: _Paths.QR_SCANNER,
          page: () => const QRScannerView(),
          binding: QRScannerBinding(),
        ),
      ],
    ),
  ];
}
