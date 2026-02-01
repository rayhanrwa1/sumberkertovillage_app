import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/news/controllers/news_controller.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<NewsController>(() => NewsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
