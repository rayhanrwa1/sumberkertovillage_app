import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 1));

    final bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      box.write('isFirstLaunch', false);
      Get.offAllNamed(Routes.WELCOME);
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    final snapshot = await FirebaseDatabase.instance
        .ref("users/${user.uid}/exp")
        .get();

    if (!snapshot.exists) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    final exp = snapshot.value as int;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (now >= exp) {
      await _auth.signOut();

      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    Get.offAllNamed(Routes.MAIN);
  }
}
