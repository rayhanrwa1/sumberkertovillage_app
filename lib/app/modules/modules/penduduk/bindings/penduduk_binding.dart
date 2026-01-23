import 'package:get/get.dart';

import '../controllers/penduduk_controller.dart';

class PendudukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PendudukController>(
      () => PendudukController(),
    );
  }
}
