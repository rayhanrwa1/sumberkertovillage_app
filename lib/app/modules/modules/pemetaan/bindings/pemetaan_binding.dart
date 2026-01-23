import 'package:get/get.dart';

import '../controllers/pemetaan_controller.dart';

class PemetaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PemetaanController>(
      () => PemetaanController(),
    );
  }
}
