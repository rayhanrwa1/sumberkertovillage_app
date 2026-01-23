import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register(BuildContext context) async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      context.showWarningSnackBar('Semua field wajib diisi');
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;

      final Map<String, dynamic> userData = {
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'admin',
        'provider': 'email',
        'created_at': ServerValue.timestamp,
      };

      await _userRef.child(uid).set(userData);

      context.showSuccessSnackBar('Pendaftaran berhasil');
      Get.offAllNamed(Routes.REGISTERSUCCESS);
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(e.message ?? 'Pendaftaran gagal');
    } catch (e) {
      context.showErrorSnackBar('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
