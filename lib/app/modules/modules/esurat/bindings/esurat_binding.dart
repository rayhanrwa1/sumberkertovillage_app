import 'package:get/get.dart';

import '../controllers/esurat_controller.dart';

class EsuratBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EsuratController>(
      () => EsuratController(),
    );
  }
}
