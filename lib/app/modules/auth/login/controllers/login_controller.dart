import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Biometric states
  final canUseBiometric = false.obs;
  final lastLoggedInEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricForLastUser();
  }

  Future<void> _checkBiometricForLastUser() async {
    try {
      final storage = FlutterSecureStorage();

      final lastEmail = await storage.read(key: 'last_email');
      final biometricEnabled = await storage.read(key: 'biometric_enabled');

      if (lastEmail == null || biometricEnabled != 'true') return;

      final biometrics = await _localAuth.getAvailableBiometrics();

      print('DEBUG availableBiometrics: $biometrics');

      if (biometrics.isNotEmpty) {
        canUseBiometric.value = true;
        lastLoggedInEmail.value = lastEmail;
        emailController.text = lastEmail;
      }
    } catch (e) {
      print('Biometric check error: $e');
    }
  }

  Future<void> loginWithBiometric(BuildContext context) async {
    try {
      isLoading.value = true;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk',
      );

      if (!authenticated) {
        context.showWarningSnackBar('Autentikasi biometrik dibatalkan');
        return;
      }

      // Ambil kredensial dari secure storage
      final storedPassword = await _getStoredPassword(lastLoggedInEmail.value);
      if (storedPassword == null) {
        context.showErrorSnackBar('Data login tidak ditemukan');
        canUseBiometric.value = false;
        return;
      }

      // Login otomatis
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: lastLoggedInEmail.value,
        password: storedPassword,
      );

      final user = userCredential.user;
      if (user == null) {
        context.showErrorSnackBar('User tidak ditemukan');
        return;
      }

      context.showSuccessSnackBar('Berhasil masuk dengan biometrik');
      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      context.showErrorSnackBar('Login biometrik gagal: ${e.toString()}');
      canUseBiometric.value = false;
    } finally {
      isLoading.value = false;
    }
  }

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

      final snapshot = await _database.child('users').child(user.uid).get();

      if (!snapshot.exists) {
        context.showErrorSnackBar('Data user tidak ditemukan di database');
        return;
      }

      // Simpan kredensial untuk biometrik
      await _saveLoginCredentials(
        emailController.text.trim(),
        passwordController.text.trim(),
        user.uid,
      );

      context.showSuccessSnackBar('Berhasil masuk');
      Get.offAllNamed(Routes.MAIN);
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(e.message ?? 'Login gagal');
    } catch (e) {
      context.showErrorSnackBar('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== HELPER METHODS =====

  Future<void> _saveLoginCredentials(
    String email,
    String password,
    String uid,
  ) async {
    // Gunakan flutter_secure_storage untuk simpan password
    final storage = FlutterSecureStorage();
    await storage.write(key: 'last_email', value: email);
    await storage.write(key: 'pwd_$email', value: password);
    await storage.write(key: 'uid_$email', value: uid);
  }

  Future<String> _getLastLoggedInEmail() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'last_email') ?? '';
  }

  Future<String?> _getStoredPassword(String email) async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'pwd_$email');
  }

  Future<String?> _getUidFromEmail(String email) async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'uid_$email');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
