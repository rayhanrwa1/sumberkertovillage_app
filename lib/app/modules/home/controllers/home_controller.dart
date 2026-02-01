import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  final totalPenduduk = 0.obs;
  RxBool isProfileComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPenduduk();
    checkProfileComplete();
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

  void checkProfileComplete() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      isProfileComplete.value = false;
      return;
    }

    final profileRef = FirebaseDatabase.instance.ref().child('profile');

    final snapshot = await profileRef.child(currentUser.uid).get();

    if (!snapshot.exists) {
      isProfileComplete.value = false;
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final hasNIK = data['nik'] != null && data['nik'].toString().isNotEmpty;
    final hasAddress =
        data['address'] != null && data['address'].toString().isNotEmpty;
    final hasPhone =
        data['phone'] != null && data['phone'].toString().isNotEmpty;
    final hasGender =
        data['gender'] != null && data['gender'].toString().isNotEmpty;
    final hasBirthDate =
        data['tanggal_lahir'] != null &&
        data['tanggal_lahir'].toString().isNotEmpty;

    isProfileComplete.value =
        hasNIK && hasAddress && hasPhone && hasGender && hasBirthDate;
  }
}
