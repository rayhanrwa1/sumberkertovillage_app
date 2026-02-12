import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  final name = ''.obs;
  final email = ''.obs;
  final role = ''.obs;
  final provider = ''.obs;

  final nik = ''.obs;
  final tanggalLahir = ''.obs;
  final username = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;
  final gender = ''.obs;
  final photoProfile = ''.obs;

  final isLoading = false.obs;

  final isBiometricEnabled = false.obs;
  final isBiometricAvailable = false.obs;
  final biometricType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometricAvailability();
  }

  Future<void> checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();

      isBiometricAvailable.value = canCheck && supported;

      if (!isBiometricAvailable.value) return;

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) {
        biometricType.value = 'Face ID';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        biometricType.value = 'Fingerprint';
      } else {
        biometricType.value = 'Biometric';
      }

      await loadBiometricSetting();
    } catch (_) {
      isBiometricAvailable.value = false;
    }
  }

  Future<void> loadBiometricSetting() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snap = await _database
        .child('profile')
        .child(user.uid)
        .child('biometrik')
        .child('enabled')
        .get();

    if (snap.exists) {
      isBiometricEnabled.value = snap.value as bool;
    } else {
      isBiometricEnabled.value = false;
    }
  }

  Future<void> toggleBiometric(BuildContext context, bool value) async {
    try {
      print('=== TOGGLE BIOMETRIC START ===');
      print('Target value: $value');
      print('Current value: ${isBiometricEnabled.value}');

      if (value) {
        print('Requesting biometric authentication...');

        // Cek apakah biometrik tersedia
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        print('Can check biometrics: $canCheck');
        print('Device supported: $isDeviceSupported');

        if (!canCheck || !isDeviceSupported) {
          context.showErrorSnackBar(
            'Biometrik tidak tersedia di perangkat ini',
          );
          return;
        }

        // Verifikasi biometrik
        bool authenticated = false;
        try {
          authenticated = await _localAuth.authenticate(
            localizedReason:
                'Verifikasi identitas untuk mengaktifkan biometrik',
          );
          print('Authentication result: $authenticated');
        } catch (authError) {
          print('Authentication error: $authError');
          context.showErrorSnackBar('Autentikasi biometrik gagal');
          return;
        }

        if (!authenticated) {
          context.showErrorSnackBar('Autentikasi biometrik dibatalkan');
          return;
        }

        print('Authentication successful!');
      }

      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: User is null');
        context.showErrorSnackBar('User tidak login');
        return;
      }

      print('User UID: ${user.uid}');
      print('Updating database...');

      // Update ke database
      // await _database.child('profile').child(user.uid).update({
      //   'biometricEnabled': value,
      // });

      final storage = FlutterSecureStorage();

      // simpan ke Firebase (opsional, untuk sinkronisasi)
      await _database.child('profile').child(user.uid).update({
        'biometricEnabled': value,
      });

      // 🔥 WAJIB: simpan ke local secure storage
      await storage.write(
        key: 'biometric_enabled',
        value: value.toString(), // "true" / "false"
      );

      print('Database updated successfully');

      // Baru update state setelah berhasil
      isBiometricEnabled.value = value;

      print('State updated: ${isBiometricEnabled.value}');

      context.showSuccessSnackBar(
        value
            ? '${biometricType.value} berhasil diaktifkan'
            : '${biometricType.value} dinonaktifkan',
      );

      print('=== TOGGLE BIOMETRIC END (SUCCESS) ===');
    } catch (e, stackTrace) {
      print('=== ERROR TOGGLING BIOMETRIC ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      context.showErrorSnackBar('Gagal mengubah pengaturan biometrik: $e');

      // Pastikan state kembali ke posisi sebelumnya jika error
      await loadBiometricSetting();
    }
  }

  Future<void> loadProfile(BuildContext context) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      print('Loading profile for UID: ${user.uid}');

      final userSnap = await _database.child('users').child(user.uid).get();
      if (userSnap.exists) {
        final data = userSnap.value as Map<dynamic, dynamic>;
        name.value = data['name'] ?? '';
        email.value = data['email'] ?? '';
        role.value = data['role'] ?? '';
        provider.value = data['provider'] ?? '';
      } else {
        email.value = user.email ?? '';
      }

      final profileSnap = await _database
          .child('profile')
          .child(user.uid)
          .get();
      if (profileSnap.exists) {
        final p = profileSnap.value as Map<dynamic, dynamic>;
        nik.value = p['nik'] ?? '';
        tanggalLahir.value = p['tanggal_lahir'] ?? '';
        username.value = p['username'] ?? '';
        phone.value = p['phone'] ?? '';
        address.value = p['address'] ?? '';
        gender.value = p['gender'] ?? '';
        photoProfile.value = p['photo_profile'] ?? '';
        print('Photo profile loaded: ${photoProfile.value}');
      }
    } catch (e) {
      print('Error loading profile: $e');
      context.showErrorSnackBar('Gagal memuat profil');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      print('Starting image picker...');
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) {
        print('No image selected');
        return;
      }

      print('Image selected: ${image.path}');
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in');
        context.showErrorSnackBar('User tidak login');
        return;
      }

      print('User UID: ${user.uid}');
      print('Uploading to Firebase Storage...');

      final ref = _storage.ref().child('avatars').child('${user.uid}.jpg');
      print('Storage path: ${ref.fullPath}');

      final uploadTask = await ref.putFile(File(image.path));
      print('Upload complete. State: ${uploadTask.state}');

      final url = await ref.getDownloadURL();
      print('Download URL: $url');

      print('Updating database...');
      await _database.child('profile').child(user.uid).update({
        'photo_profile': url,
        'updated_at': DateTime.now().toIso8601String(),
      });

      photoProfile.value = url;
      print('Photo profile updated successfully');
      context.showSuccessSnackBar('Foto profil diperbarui');
    } catch (e) {
      print('Error uploading photo: $e');
      print('Error type: ${e.runtimeType}');
      context.showErrorSnackBar('Gagal upload foto: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToEditProfile(BuildContext context) async {
    final result = await Get.toNamed(Routes.EDITPROFILE);
    if (result == true) {
      loadProfile(context);
    }
  }

  void goToChangePassword(BuildContext context) {
    if (provider.value == 'google.com') {
      context.showInfoSnackBar('Login Google tidak bisa ubah password');
      return;
    }
    Get.toNamed(Routes.CHANGEPASSWORD);
  }

  Future<void> logout(BuildContext context) async {
    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          content: const Text(
            'Keluar dari aplikasi?',
            style: TextStyle(color: Colors.black87),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await _auth.signOut();
                Get.offAllNamed(Routes.LOGIN);
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false, // opsional (biar ga ketutup tap luar)
      );
    } catch (e) {
      context.showErrorSnackBar('Gagal logout');
    }
  }
}
