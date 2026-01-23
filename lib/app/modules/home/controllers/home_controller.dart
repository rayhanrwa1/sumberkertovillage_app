import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeController extends GetxController {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  final totalPenduduk = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPenduduk();
  }

  void loadPenduduk() async {
    final snapshot = await _userRef
        .orderByChild('role')
        .equalTo('penduduk')
        .get();

    if (snapshot.exists) {
      totalPenduduk.value = snapshot.children.length;
    } else {
      totalPenduduk.value = 0;
    }
  }
}
