import 'package:get/get.dart';

import '../controllers/pertanian_controller.dart';

class PertanianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PertanianController>(
      () => PertanianController(),
    );
  }
}
