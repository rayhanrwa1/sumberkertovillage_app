import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void togglePassword() {
    isPasswordHidden.toggle();
  }

  // ===============================
  // REGISTER EMAIL
  // ===============================
  Future<void> register(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      context.showWarningSnackBar('Semua field wajib diisi');
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("User tidak ditemukan");

      final uid = user.uid;

      await _database.child('users').child(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user',
        'provider': 'email',
        'created_at': ServerValue.timestamp,
      });

      await _database.child('profile').child(uid).set({
        'username': emailController.text.split('@')[0],
        'photo_profile': '',
        'created_at': ServerValue.timestamp,
        'updated_at': ServerValue.timestamp,
      });

      context.showSuccessSnackBar('Pendaftaran berhasil');
      Get.offAllNamed(Routes.REGISTERSUCCESS);
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(_firebaseErrorMessage(e));
    } catch (_) {
      context.showErrorSnackBar('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  // ===============================
  // REGISTER WITH GOOGLE (V7 FIX)
  // ===============================
  Future<void> registerWithGoogle(BuildContext context) async {
    try {
      isGoogleLoading.value = true;

      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("ID Token tidak ditemukan");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception("User tidak ditemukan");

      final uid = user.uid;

      final snapshot = await _database.child('users').child(uid).get();

      if (snapshot.exists) {
        await _auth.signOut();
        await googleSignIn.signOut();

        context.showWarningSnackBar('Akun sudah terdaftar, silakan login');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      await _database.child('users').child(uid).set({
        'uid': uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'role': 'user',
        'provider': 'google',
        'created_at': ServerValue.timestamp,
      });

      await _database.child('profile').child(uid).set({
        'username': user.email?.split('@')[0] ?? 'user_${uid.substring(0, 8)}',
        'photo_profile': user.photoURL ?? '',
        'created_at': ServerValue.timestamp,
        'updated_at': ServerValue.timestamp,
      });

      context.showSuccessSnackBar('Pendaftaran dengan Google berhasil');
      Get.offAllNamed(Routes.REGISTERSUCCESS);
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(_firebaseErrorMessage(e));
    } catch (e) {
      context.showErrorSnackBar('Google Sign-In gagal: ${e.toString()}');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ===============================
  // ERROR HANDLER
  // ===============================
  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'account-exists-with-different-credential':
        return 'Akun sudah terdaftar dengan metode lain';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'operation-not-allowed':
        return 'Metode login belum diaktifkan di Firebase';
      default:
        return e.message ?? 'Terjadi kesalahan';
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
