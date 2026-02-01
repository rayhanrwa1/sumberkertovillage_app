import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> changePassword() async {
    // Validation
    if (currentPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password saat ini harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password baru harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password baru minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      Get.snackbar(
        'Error',
        'Password baru harus berbeda dengan password saat ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User tidak ditemukan');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPasswordController.text);

      Get.snackbar(
        'Sukses',
        'Password berhasil diubah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Go back to profile
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal mengubah password';

      if (e.code == 'wrong-password') {
        errorMessage = 'Password saat ini salah';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Silakan login ulang dan coba lagi';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
