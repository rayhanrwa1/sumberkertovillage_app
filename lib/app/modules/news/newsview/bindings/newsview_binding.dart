import 'package:get/get.dart';

import '../controllers/newsview_controller.dart';

class NewsviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsviewController>(
      () => NewsviewController(),
    );
  }
}
