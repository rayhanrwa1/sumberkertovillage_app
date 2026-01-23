import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();

  final isLoading = false.obs;

  late String verificationId;
  late String phone;
  late String name;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void onInit() {
    super.onInit();
    verificationId = Get.arguments['verificationId'];
    phone = Get.arguments['phone'];
    name = Get.arguments['name'];
  }

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      await _db.child('users').child(uid).set({
        'name': name,
        'phone': phone,
        'userable_type': 'admin',
        'provider': 'phone',
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.offAllNamed(Routes.REGISTERSUCCESS, arguments: {'phone': phone});
    } on FirebaseAuthException catch (e) {
      Get.snackbar('OTP Salah', e.message ?? 'Kode tidak valid');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
