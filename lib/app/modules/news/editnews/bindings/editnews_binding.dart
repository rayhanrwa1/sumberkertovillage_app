import 'package:get/get.dart';

import '../controllers/editnews_controller.dart';

class EditnewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditnewsController>(
      () => EditnewsController(),
    );
  }
}
