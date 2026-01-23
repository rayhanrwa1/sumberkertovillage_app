import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class RegistersuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();

    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.LOGIN);
    });
  }
}
