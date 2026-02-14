import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final canUseBiometric = false.obs;
  final lastLoggedInEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricForLastUser();
  }

  // =========================
  // EXP CALCULATION (4 HARI)
  // =========================
  int _generateExpTimestamp() {
    final now = DateTime.now();
    final expired = now.add(const Duration(days: 4));
    return expired.millisecondsSinceEpoch;
  }

  Future<void> _saveExpToDatabase(String uid) async {
    final expTimestamp = _generateExpTimestamp();

    await _database.child('users').child(uid).update({
      'exp': expTimestamp,
      'last_login': ServerValue.timestamp,
    });
  }

  // =========================
  // LOGIN EMAIL
  // =========================
  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      context.showWarningSnackBar('Email dan password wajib diisi');
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

      // ✅ SET EXP 4 HARI
      await _saveExpToDatabase(user.uid);

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

  // =========================
  // LOGIN GOOGLE (ICON SAMA)
  // =========================
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      isGoogleLoading.value = true;

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        context.showErrorSnackBar('User tidak ditemukan');
        return;
      }

      // ✅ SET EXP 4 HARI
      await _saveExpToDatabase(user.uid);

      context.showSuccessSnackBar('Login dengan Google berhasil');
      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      context.showErrorSnackBar('Google login gagal');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // =========================
  // BIOMETRIC
  // =========================
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

      final storedPassword = await _getStoredPassword(lastLoggedInEmail.value);

      if (storedPassword == null) {
        context.showErrorSnackBar('Data login tidak ditemukan');
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: lastLoggedInEmail.value,
        password: storedPassword,
      );

      final user = userCredential.user;
      if (user == null) {
        context.showErrorSnackBar('User tidak ditemukan');
        return;
      }

      await _saveExpToDatabase(user.uid);

      context.showSuccessSnackBar('Berhasil masuk dengan biometrik');
      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      context.showErrorSnackBar('Login biometrik gagal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkBiometricForLastUser() async {
    try {
      final storage = const FlutterSecureStorage();

      final lastEmail = await storage.read(key: 'last_email');
      final biometricEnabled = await storage.read(key: 'biometric_enabled');

      if (lastEmail == null || biometricEnabled != 'true') return;

      final biometrics = await _localAuth.getAvailableBiometrics();

      if (biometrics.isNotEmpty) {
        canUseBiometric.value = true;
        lastLoggedInEmail.value = lastEmail;
        emailController.text = lastEmail;
      }
    } catch (e) {
      print('Biometric check error: $e');
    }
  }

  void togglePassword() {
    isPasswordHidden.toggle();
  }

  // =========================
  // STORAGE
  // =========================
  Future<void> _saveLoginCredentials(
    String email,
    String password,
    String uid,
  ) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'last_email', value: email);
    await storage.write(key: 'pwd_$email', value: password);
    await storage.write(key: 'uid_$email', value: uid);
  }

  Future<String?> _getStoredPassword(String email) async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'pwd_$email');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
