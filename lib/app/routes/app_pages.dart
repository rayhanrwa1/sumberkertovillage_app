import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/village_profile/views/Manage_kepala_desa_history.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/village_profile/views/Manage_timeline_sejarah_view.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/village_profile/views/manage_organize.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/village_profile/views/village_data_manage.dart';

import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/otp/bindings/otp_binding.dart';
import '../modules/auth/otp/views/otp_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/auth/registersuccess/bindings/registersuccess_binding.dart';
import '../modules/auth/registersuccess/views/registersuccess_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/modules/pemetaan/bindings/pemetaan_binding.dart';
import '../modules/modules/pemetaan/views/pemetaan_view.dart';
import '../modules/modules/penduduk/bindings/penduduk_binding.dart';
import '../modules/modules/penduduk/views/penduduk_view.dart';
import '../modules/news/bindings/news_binding.dart';
import '../modules/news/editnews/bindings/editnews_binding.dart';
import '../modules/news/editnews/views/editnews_view.dart';
import '../modules/news/newsview/bindings/newsview_binding.dart';
import '../modules/news/newsview/views/newsview_view.dart';
import '../modules/news/views/news_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/changepassword/bindings/changepassword_binding.dart';
import '../modules/profile/changepassword/views/changepassword_view.dart';
import '../modules/profile/editprofile/bindings/editprofile_binding.dart';
import '../modules/profile/editprofile/views/editprofile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/modules/village_profile/bindings/village_profile_binding.dart';
import '../modules/modules/village_profile/views/village_profile_view.dart';
import '../modules/modules/village_profile/views/village_profile_edit_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.REGISTERSUCCESS,
      page: () => const RegistersuccessView(),
      binding: RegistersuccessBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.PEMETAAN,
      page: () => const PemetaanView(),
      binding: PemetaanBinding(),
    ),
    GetPage(
      name: _Paths.PENDUDUK,
      page: () => const PendudukView(),
      binding: PendudukBinding(),
    ),
    GetPage(
      name: _Paths.EDITPROFILE,
      page: () => const EditprofileView(),
      binding: EditprofileBinding(),
    ),
    GetPage(
      name: _Paths.CHANGEPASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangepasswordBinding(),
    ),
    GetPage(
      name: _Paths.NEWS,
      page: () => const NewsView(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: _Paths.EDITNEWS,
      page: () => const EditnewsView(),
      binding: EditnewsBinding(),
    ),
    GetPage(
      name: _Paths.NEWSVIEW,
      page: () => const NewsviewView(),
      binding: NewsviewBinding(),
    ),
    GetPage(
      name: _Paths.VILLAGE_PROFILE,
      page: () => const VillageProfileView(),
      binding: VillageProfileBinding(),
    ),
    GetPage(
      name: _Paths.VILLAGE_PROFILE_EDIT,
      page: () => const VillageProfileEditView(),
      binding: VillageProfileBinding(),
    ),
    GetPage(
      name: _Paths.VILLAGE_DATA_MANAGE,
      page: () => const VillageDataManageView(),
      binding: VillageProfileBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_ORGANIZATION,
      page: () => const ManageOrganizationView(),
      binding: VillageProfileBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_KEPALA_DESA_HISTORY,
      page: () => const ManageKepalaDesaHistoryView(),
      binding: VillageProfileBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_TIMELINE_SEJARAH,
      page: () => const ManageTimelineSejarahView(),
      binding: VillageProfileBinding(),
    ),
  ];
}
