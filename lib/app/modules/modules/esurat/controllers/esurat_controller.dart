import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/esurat_model.dart';

class EsuratController extends GetxController {
  final db = FirebaseDatabase.instance.ref();

  final FirebaseAuth auth = FirebaseAuth.instance;

  var loading = false.obs;

  var esuratList = <EsuratModel>[].obs;

  /// CREATE SURAT
  Future createSurat({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      loading.value = true;

      String uid = auth.currentUser!.uid;

      String id = const Uuid().v4();

      EsuratModel surat = EsuratModel(
        id: id,
        type: type,
        generate: false,
        status: "draft",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        data: data,
        nomor: "",
        fileUrl: "",
      );

      await db.child("esurat").child(uid).child(id).set(surat.toJson());

      Get.snackbar("Sukses", "Surat berhasil dibuat");

      getSurat();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      loading.value = false;
    }
  }

  /// GET SURAT
  Future getSurat() async {
    try {
      String uid = auth.currentUser!.uid;

      DatabaseEvent event = await db.child("esurat").child(uid).once();

      if (event.snapshot.value == null) {
        esuratList.clear();

        return;
      }

      Map data = event.snapshot.value as Map;

      esuratList.value = data.entries.map((e) {
        return EsuratModel.fromJson(e.key, Map<String, dynamic>.from(e.value));
      }).toList();
    } catch (e) {
      print(e);
    }
  }

  /// UPDATE GENERATE STATUS

  Future setGenerateTrue(String id) async {
    String uid = auth.currentUser!.uid;

    await db.child("esurat").child(uid).child(id).update({
      "generate": true,
      "status": "selesai",
    });
  }

  @override
  void onInit() {
    getSurat();

    super.onInit();
  }
}
