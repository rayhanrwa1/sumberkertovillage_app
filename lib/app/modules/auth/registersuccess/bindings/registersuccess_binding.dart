import 'package:get/get.dart';

import '../controllers/registersuccess_controller.dart';

class RegistersuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistersuccessController>(
      () => RegistersuccessController(),
    );
  }
}
