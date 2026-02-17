import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  final box = GetStorage();

  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final user = FirebaseAuth.instance.currentUser;

    /// Tidak login
    if (user == null) {
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    /// Ambil exp dari realtime database
    final snapshot = await FirebaseDatabase.instance
        .ref("users/${user.uid}/exp")
        .get();

    if (!snapshot.exists) {
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    final exp = snapshot.value as int;

    final now = DateTime.now().millisecondsSinceEpoch;

    /// Kalau expired
    if (now >= exp) {
      await FirebaseAuth.instance.signOut();

      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    return await super.redirectDelegate(route);
  }
}
