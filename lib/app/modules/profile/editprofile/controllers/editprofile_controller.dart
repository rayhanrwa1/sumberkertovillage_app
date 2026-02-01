import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';

class EditprofileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nikController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Observable
  final selectedGender = ''.obs;
  final isLoading = false.obs;
  final isFormValid = false.obs;
  final genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void onInit() {
    super.onInit();

    void validateForm() {
      isFormValid.value =
          nikController.text.length == 16 &&
          tanggalLahirController.text.isNotEmpty &&
          usernameController.text.length >= 3 &&
          phoneController.text.length >= 10 &&
          addressController.text.length >= 10 &&
          selectedGender.value.isNotEmpty;
    }

    nikController.addListener(validateForm);
    tanggalLahirController.addListener(validateForm);
    usernameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    addressController.addListener(validateForm);
    ever(selectedGender, (_) => validateForm());
  }

  @override
  void onClose() {
    nikController.dispose();
    tanggalLahirController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // ================= LOAD PROFILE =================
  Future<void> loadProfileData(BuildContext context) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final snapshot = await _database.child('profile').child(user.uid).get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          nikController.text = data['nik'] ?? '';
          tanggalLahirController.text = data['tanggal_lahir'] ?? '';
          usernameController.text = data['username'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          selectedGender.value = data['gender'] ?? '';
        }
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DATE PICKER =================
  void selectDate(BuildContext context) {
    DateTime initialDate = DateTime(2000);

    if (tanggalLahirController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(tanggalLahirController.text);
      } catch (_) {}
    }

    BottomPicker.date(
      pickerTitle: const Text(
        'Pilih Tanggal Lahir',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: initialDate,
      maxDateTime: DateTime.now(),
      minDateTime: DateTime(1940),
      onSubmit: (date) {
        tanggalLahirController.text = date.toString().split(' ')[0];
      },
      bottomPickerTheme: BottomPickerTheme.blue,
    ).show(context);
  }

  // ================= VALIDATION =================
  String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK tidak boleh kosong';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'No. telepon tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'No. telepon minimal 10 digit';
    }
    return null;
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile(BuildContext context) async {
    if (isLoading.value) return;

    if (!formKey.currentState!.validate()) return;

    if (selectedGender.value.isEmpty) {
      context.showWarningSnackBar('Jenis kelamin harus dipilih');
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      await _database.child('profile').child(user.uid).update({
        'nik': nikController.text,
        'tanggal_lahir': tanggalLahirController.text,
        'username': usernameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'gender': selectedGender.value,
        'updated_at': DateTime.now().toIso8601String(),
      });

      context.showSuccessSnackBar('Profil berhasil diperbarui');

      await Future.delayed(const Duration(milliseconds: 600));
      Get.back(result: true);
    } catch (e) {
      context.showErrorSnackBar('Gagal memperbarui profil: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
