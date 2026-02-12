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

  // ================= REQUIRED FIELDS =================
  // Text Controllers - REQUIRED
  final nikController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // ================= OPTIONAL FIELDS =================
  // Text Controllers - OPTIONAL
  final tempatLahirController = TextEditingController();
  final pekerjaanController = TextEditingController();
  final pendidikanController = TextEditingController();
  final kewarganegaraanController = TextEditingController();
  final agamaController = TextEditingController();
  final namaAyahController = TextEditingController();
  final namaIbuController = TextEditingController();

  // Observable - REQUIRED
  final selectedGender = ''.obs;
  final selectedDusun = ''.obs;
  final selectedRW = ''.obs;
  final selectedRT = ''.obs;

  // Observable - OPTIONAL
  final selectedStatusKawin = ''.obs;
  final selectedGolonganDarah = ''.obs;
  final selectedPendidikan = ''.obs;
  final selectedPekerjaan = ''.obs;
  final selectedAgama = ''.obs;
  final selectedStatusKeluarga = ''.obs;

  final isLoading = false.obs;
  final isFormValid = false.obs;

  // ================= DROPDOWN OPTIONS =================
  // REQUIRED Options
  final genderOptions = ['Laki-laki', 'Perempuan'];
  final dusunOptions = ['Sumberwader', 'Krajan', 'Kaligading'];
  final rwOptions = List.generate(6, (i) => 'RW ${i + 1}');
  final rtOptions = List.generate(
    20,
    (i) => 'RT ${i + 1}',
  ); // Sesuaikan jumlah RT

  // OPTIONAL Options
  final statusKawinOptions = [
    'Belum Kawin',
    'Kawin',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  final golonganDarahOptions = ['A', 'B', 'AB', 'O', 'Tidak Tahu'];

  final pendidikanOptions = [
    'Tidak/Belum Sekolah',
    'Belum Tamat SD/Sederajat',
    'Tamat SD/Sederajat',
    'SLTP/Sederajat',
    'SLTA/Sederajat',
    'Diploma I/II',
    'Akademi/Diploma III/S.Muda',
    'Diploma IV/Strata I',
    'Strata II',
    'Strata III',
  ];

  final pekerjaanOptions = [
    'Belum/Tidak Bekerja',
    'Mengurus Rumah Tangga',
    'Pelajar/Mahasiswa',
    'Pensiunan',
    'Pegawai Negeri Sipil',
    'Tentara Nasional Indonesia',
    'Kepolisian RI',
    'Perdagangan',
    'Petani/Pekebun',
    'Peternak',
    'Nelayan/Perikanan',
    'Industri',
    'Konstruksi',
    'Transportasi',
    'Karyawan Swasta',
    'Karyawan BUMN',
    'Karyawan BUMD',
    'Karyawan Honorer',
    'Buruh Harian Lepas',
    'Buruh Tani/Perkebunan',
    'Buruh Nelayan/Perikanan',
    'Buruh Peternakan',
    'Pembantu Rumah Tangga',
    'Tukang Cukur',
    'Tukang Listrik',
    'Tukang Batu',
    'Tukang Kayu',
    'Tukang Sol Sepatu',
    'Tukang Las/Pandai Besi',
    'Tukang Jahit',
    'Tukang Gigi',
    'Penata Rias',
    'Penata Busana',
    'Penata Rambut',
    'Mekanik',
    'Seniman',
    'Tabib',
    'Paraji',
    'Perancang Busana',
    'Penterjemah',
    'Imam Masjid',
    'Pendeta',
    'Pastor',
    'Wartawan',
    'Ustadz/Mubaligh',
    'Juru Masak',
    'Promotor Acara',
    'Anggota DPR-RI',
    'Anggota DPD',
    'Anggota BPK',
    'Presiden',
    'Wakil Presiden',
    'Anggota Mahkamah Konstitusi',
    'Anggota Kabinet/Kementerian',
    'Duta Besar',
    'Gubernur',
    'Wakil Gubernur',
    'Bupati',
    'Wakil Bupati',
    'Walikota',
    'Wakil Walikota',
    'Anggota DPRD Provinsi',
    'Anggota DPRD Kabupaten/Kota',
    'Dosen',
    'Guru',
    'Pilot',
    'Pengacara',
    'Notaris',
    'Arsitek',
    'Akuntan',
    'Konsultan',
    'Dokter',
    'Bidan',
    'Perawat',
    'Apoteker',
    'Psikiater/Psikolog',
    'Penyiar Televisi',
    'Penyiar Radio',
    'Pelaut',
    'Peneliti',
    'Sopir',
    'Pialang',
    'Paranormal',
    'Pedagang',
    'Perangkat Desa',
    'Kepala Desa',
    'Biarawati',
    'Wiraswasta',
    'Lainnya',
  ];

  final agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu',
    'Kepercayaan Kepada Tuhan YME',
  ];

  final statusKeluargaOptions = [
    'Pra Sejahtera',
    'Sejahtera I',
    'Sejahtera II',
    'Sejahtera III',
    'Sejahtera III Plus',
  ];

  @override
  void onInit() {
    super.onInit();

    void validateForm() {
      // Validasi hanya untuk field REQUIRED
      isFormValid.value =
          nikController.text.length == 16 &&
          tanggalLahirController.text.isNotEmpty &&
          usernameController.text.length >= 3 &&
          phoneController.text.length >= 10 &&
          addressController.text.length >= 10 &&
          selectedGender.value.isNotEmpty &&
          selectedDusun.value.isNotEmpty &&
          selectedRW.value.isNotEmpty &&
          selectedRT.value.isNotEmpty;
    }

    // REQUIRED listeners
    nikController.addListener(validateForm);
    tanggalLahirController.addListener(validateForm);
    usernameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    addressController.addListener(validateForm);
    ever(selectedGender, (_) => validateForm());
    ever(selectedDusun, (_) => validateForm());
    ever(selectedRW, (_) => validateForm());
    ever(selectedRT, (_) => validateForm());
  }

  @override
  void onClose() {
    // Dispose REQUIRED controllers
    nikController.dispose();
    tanggalLahirController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();

    // Dispose OPTIONAL controllers
    tempatLahirController.dispose();
    pekerjaanController.dispose();
    pendidikanController.dispose();
    kewarganegaraanController.dispose();
    agamaController.dispose();
    namaAyahController.dispose();
    namaIbuController.dispose();

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

          // REQUIRED fields
          nikController.text = data['nik'] ?? '';
          tanggalLahirController.text = data['tanggal_lahir'] ?? '';
          usernameController.text = data['username'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          selectedGender.value = data['gender'] ?? '';
          selectedDusun.value = data['dusun'] ?? '';
          selectedRW.value = data['rw'] ?? '';
          selectedRT.value = data['rt'] ?? '';

          // OPTIONAL fields
          tempatLahirController.text = data['tempat_lahir'] ?? '';
          selectedStatusKawin.value = data['status_kawin'] ?? '';
          selectedGolonganDarah.value = data['golongan_darah'] ?? '';
          selectedPendidikan.value = data['pendidikan'] ?? '';
          selectedPekerjaan.value = data['pekerjaan'] ?? '';
          selectedAgama.value = data['agama'] ?? '';
          kewarganegaraanController.text = data['kewarganegaraan'] ?? '';
          namaAyahController.text = data['nama_ayah'] ?? '';
          namaIbuController.text = data['nama_ibu'] ?? '';
          selectedStatusKeluarga.value = data['status_keluarga'] ?? '';
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

  // ================= VALIDATION (REQUIRED ONLY) =================
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

    // Validasi REQUIRED dropdowns
    if (selectedGender.value.isEmpty) {
      context.showWarningSnackBar('Jenis kelamin harus dipilih');
      return;
    }

    if (selectedDusun.value.isEmpty) {
      context.showWarningSnackBar('Dusun harus dipilih');
      return;
    }

    if (selectedRW.value.isEmpty) {
      context.showWarningSnackBar('RW harus dipilih');
      return;
    }

    if (selectedRT.value.isEmpty) {
      context.showWarningSnackBar('RT harus dipilih');
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      // Prepare data - include both REQUIRED and OPTIONAL fields
      Map<String, dynamic> profileData = {
        // REQUIRED fields
        'nik': nikController.text,
        'tanggal_lahir': tanggalLahirController.text,
        'username': usernameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'gender': selectedGender.value,
        'dusun': selectedDusun.value,
        'rw': selectedRW.value,
        'rt': selectedRT.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // OPTIONAL fields - only add if not empty
      if (tempatLahirController.text.isNotEmpty) {
        profileData['tempat_lahir'] = tempatLahirController.text;
      }
      if (selectedStatusKawin.value.isNotEmpty) {
        profileData['status_kawin'] = selectedStatusKawin.value;
      }
      if (selectedGolonganDarah.value.isNotEmpty) {
        profileData['golongan_darah'] = selectedGolonganDarah.value;
      }
      if (selectedPendidikan.value.isNotEmpty) {
        profileData['pendidikan'] = selectedPendidikan.value;
      }
      if (selectedPekerjaan.value.isNotEmpty) {
        profileData['pekerjaan'] = selectedPekerjaan.value;
      }
      if (selectedAgama.value.isNotEmpty) {
        profileData['agama'] = selectedAgama.value;
      }
      if (kewarganegaraanController.text.isNotEmpty) {
        profileData['kewarganegaraan'] = kewarganegaraanController.text;
      }
      if (namaAyahController.text.isNotEmpty) {
        profileData['nama_ayah'] = namaAyahController.text;
      }
      if (namaIbuController.text.isNotEmpty) {
        profileData['nama_ibu'] = namaIbuController.text;
      }
      if (selectedStatusKeluarga.value.isNotEmpty) {
        profileData['status_keluarga'] = selectedStatusKeluarga.value;
      }

      await _database.child('profile').child(user.uid).update(profileData);

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
