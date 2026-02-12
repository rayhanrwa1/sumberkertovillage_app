import 'package:get/get.dart';

import '../controllers/village_profile_controller.dart';

class VillageProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VillageProfileController>(
      () => VillageProfileController(),
    );
  }
}
