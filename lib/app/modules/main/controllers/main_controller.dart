import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MainController extends GetxController {
  final index = 0.obs;

  void changeTab(int i) {
    index.value = i;
  }
}
