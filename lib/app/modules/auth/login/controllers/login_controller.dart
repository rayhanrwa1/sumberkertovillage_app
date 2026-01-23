import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
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

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      context.showWarningSnackBar('Email dan kata sandi wajib diisi');
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        context.showErrorSnackBar('User tidak ditemukan');
        return;
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        context.showInfoSnackBar(
          'Email belum diverifikasi. Link verifikasi telah dikirim.',
        );
        await _auth.signOut();
        return;
      }

      final snapshot = await _userRef.child(user.uid).get();

      if (!snapshot.exists) {
        context.showErrorSnackBar('Data user tidak ditemukan di database');
        return;
      }

      final Map<String, dynamic> userData = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      context.showSuccessSnackBar('Berhasil masuk');

      // Masuk ke root tab (Home, History, Profile)
      Get.offAllNamed(Routes.MAIN);
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(e.message ?? 'Login gagal');
    } catch (e) {
      context.showErrorSnackBar('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
