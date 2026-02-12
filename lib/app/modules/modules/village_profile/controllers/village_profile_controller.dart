import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';

class VillageProfileController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  final isLoading = false.obs;
  final isAdmin = false.obs;
  final villageData = <String, dynamic>{}.obs;
  final dataExists = false.obs; // Track if data already exists

  // Form Controllers untuk Admin Edit (Basic Info)
  final formKey = GlobalKey<FormState>();
  final namaDesaController = TextEditingController();
  final kecamatanController = TextEditingController();
  final kabupatenController = TextEditingController();
  final provinsiController = TextEditingController();
  final ketinggianController = TextEditingController();
  final luasWilayahController = TextEditingController();
  final kepalaDesaController = TextEditingController();
  final tahunMenjabatController = TextEditingController();
  final visiController = TextEditingController();
  final misiController = TextEditingController();
  final jarakKecamatanController = TextEditingController();
  final waktuKeKecamatanController = TextEditingController();
  final jarakKabupatenController = TextEditingController();
  final waktuKeKabupatenController = TextEditingController();

  // Additional Info Controllers
  final sejarahSingkatController = TextEditingController();
  final asalUsulNamaController = TextEditingController();
  final batasUtaraController = TextEditingController();
  final batasSelatanController = TextEditingController();
  final batasBaratController = TextEditingController();
  final batasTimurController = TextEditingController();

  // Demografi Controllers
  final jumlahDusunController = TextEditingController();
  final namaDusunController = TextEditingController();
  final jumlahRwController = TextEditingController();
  final jumlahRtController = TextEditingController();
  final totalPendudukController = TextEditingController();
  final lakiLakiController = TextEditingController();
  final perempuanController = TextEditingController();
  final totalKkController = TextEditingController();

  // Lahan Controllers
  final lahanPemukimanController = TextEditingController();
  final lahanPertanianController = TextEditingController();
  final lahanPerkebunanController = TextEditingController();
  final lahanPerkantoran = TextEditingController();
  final lahanSekolahController = TextEditingController();
  final lahanOlahragaController = TextEditingController();
  final lahanPemakamanController = TextEditingController();
  final lahanJalanController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkAdminRole();
    loadVillageData();
  }

  @override
  void onClose() {
    // Dispose all controllers
    namaDesaController.dispose();
    kecamatanController.dispose();
    kabupatenController.dispose();
    provinsiController.dispose();
    ketinggianController.dispose();
    luasWilayahController.dispose();
    kepalaDesaController.dispose();
    tahunMenjabatController.dispose();
    visiController.dispose();
    misiController.dispose();
    jarakKecamatanController.dispose();
    waktuKeKecamatanController.dispose();
    jarakKabupatenController.dispose();
    waktuKeKabupatenController.dispose();
    sejarahSingkatController.dispose();
    asalUsulNamaController.dispose();
    batasUtaraController.dispose();
    batasSelatanController.dispose();
    batasBaratController.dispose();
    batasTimurController.dispose();
    jumlahDusunController.dispose();
    namaDusunController.dispose();
    jumlahRwController.dispose();
    jumlahRtController.dispose();
    totalPendudukController.dispose();
    lakiLakiController.dispose();
    perempuanController.dispose();
    totalKkController.dispose();
    lahanPemukimanController.dispose();
    lahanPertanianController.dispose();
    lahanPerkebunanController.dispose();
    lahanPerkantoran.dispose();
    lahanSekolahController.dispose();
    lahanOlahragaController.dispose();
    lahanPemakamanController.dispose();
    lahanJalanController.dispose();
    super.onClose();
  }

  // ================= CHECK ADMIN ROLE =================
  Future<void> checkAdminRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      isAdmin.value = false;
      return;
    }

    try {
      final snapshot = await _database.child('users/${user.uid}/role').get();

      if (snapshot.exists) {
        isAdmin.value = snapshot.value.toString().toLowerCase() == 'admin';
      } else {
        isAdmin.value = false;
      }
    } catch (e) {
      print('Error checking admin role: $e');
      isAdmin.value = false;
    }
  }

  // ================= LOAD VILLAGE DATA =================
  Future<void> loadVillageData() async {
    try {
      isLoading.value = true;

      final snapshot = await _database.child('village_profile').get();

      if (snapshot.exists) {
        villageData.value = Map<String, dynamic>.from(snapshot.value as Map);
        dataExists.value = true;
      } else {
        villageData.value = {};
        dataExists.value = false;
      }

      // Populate form controllers
      _populateControllers();
    } catch (e) {
      print('Error loading village data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= POPULATE FORM CONTROLLERS =================
  void _populateControllers() {
    // Basic Info
    namaDesaController.text = villageData['nama_desa'] ?? '';
    kecamatanController.text = villageData['kecamatan'] ?? '';
    kabupatenController.text = villageData['kabupaten'] ?? '';
    provinsiController.text = villageData['provinsi'] ?? '';
    ketinggianController.text = villageData['ketinggian'] ?? '';
    luasWilayahController.text = villageData['luas_wilayah'] ?? '';
    kepalaDesaController.text = villageData['kepala_desa'] ?? '';
    tahunMenjabatController.text = villageData['tahun_menjabat'] ?? '';
    visiController.text = villageData['visi'] ?? '';
    sejarahSingkatController.text = villageData['sejarah_singkat'] ?? '';
    asalUsulNamaController.text = villageData['asal_usul_nama'] ?? '';

    // Batas Wilayah
    batasUtaraController.text = villageData['batas_utara'] ?? '';
    batasSelatanController.text = villageData['batas_selatan'] ?? '';
    batasBaratController.text = villageData['batas_barat'] ?? '';
    batasTimurController.text = villageData['batas_timur'] ?? '';

    // Wilayah Administratif
    jumlahDusunController.text = villageData['jumlah_dusun']?.toString() ?? '0';
    jumlahRwController.text = villageData['jumlah_rw']?.toString() ?? '0';
    jumlahRtController.text = villageData['jumlah_rt']?.toString() ?? '0';

    // Nama dusun as string (comma separated)
    if (villageData['nama_dusun'] is List) {
      namaDusunController.text = (villageData['nama_dusun'] as List).join(', ');
    }

    // Demografi
    totalPendudukController.text =
        villageData['total_penduduk']?.toString() ?? '0';
    lakiLakiController.text = villageData['laki_laki']?.toString() ?? '0';
    perempuanController.text = villageData['perempuan']?.toString() ?? '0';
    totalKkController.text = villageData['total_kk']?.toString() ?? '0';

    // Jarak Tempuh
    jarakKecamatanController.text = villageData['jarak_kecamatan'] ?? '';
    waktuKeKecamatanController.text = villageData['waktu_ke_kecamatan'] ?? '';
    jarakKabupatenController.text = villageData['jarak_kabupaten'] ?? '';
    waktuKeKabupatenController.text = villageData['waktu_ke_kabupaten'] ?? '';

    // Lahan
    lahanPemukimanController.text = villageData['lahan_pemukiman'] ?? '';
    lahanPertanianController.text = villageData['lahan_pertanian'] ?? '';
    lahanPerkebunanController.text = villageData['lahan_perkebunan'] ?? '';
    lahanPerkantoran.text = villageData['lahan_perkantoran'] ?? '';
    lahanSekolahController.text = villageData['lahan_sekolah'] ?? '';
    lahanOlahragaController.text = villageData['lahan_olahraga'] ?? '';
    lahanPemakamanController.text = villageData['lahan_pemakaman'] ?? '';
    lahanJalanController.text = villageData['lahan_jalan'] ?? '';

    // Misi as string (will be split into list when saving)
    if (villageData['misi'] is List) {
      misiController.text = (villageData['misi'] as List)
          .map((e) => '• $e')
          .join('\n');
    }
  }

  // ================= CREATE OR UPDATE BASIC INFO =================
  Future<void> saveBasicInfo(BuildContext context) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Split misi from multiline text to list
      final misiList = misiController.text
          .split('\n')
          .map((e) => e.trim().replaceFirst('•', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Parse nama dusun
      final namaDusunList = namaDusunController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final dataToSave = {
        'nama_desa': namaDesaController.text,
        'kecamatan': kecamatanController.text,
        'kabupaten': kabupatenController.text,
        'provinsi': provinsiController.text,
        'ketinggian': ketinggianController.text,
        'luas_wilayah': luasWilayahController.text,
        'kepala_desa': kepalaDesaController.text,
        'tahun_menjabat': tahunMenjabatController.text,
        'visi': visiController.text,
        'misi': misiList,
        'sejarah_singkat': sejarahSingkatController.text,
        'asal_usul_nama': asalUsulNamaController.text,
        'batas_utara': batasUtaraController.text,
        'batas_selatan': batasSelatanController.text,
        'batas_barat': batasBaratController.text,
        'batas_timur': batasTimurController.text,
        'jumlah_dusun': int.tryParse(jumlahDusunController.text) ?? 0,
        'nama_dusun': namaDusunList,
        'jumlah_rw': int.tryParse(jumlahRwController.text) ?? 0,
        'jumlah_rt': int.tryParse(jumlahRtController.text) ?? 0,
        'total_penduduk': int.tryParse(totalPendudukController.text) ?? 0,
        'laki_laki': int.tryParse(lakiLakiController.text) ?? 0,
        'perempuan': int.tryParse(perempuanController.text) ?? 0,
        'total_kk': int.tryParse(totalKkController.text) ?? 0,
        'jarak_kecamatan': jarakKecamatanController.text,
        'waktu_ke_kecamatan': waktuKeKecamatanController.text,
        'jarak_kabupaten': jarakKabupatenController.text,
        'waktu_ke_kabupaten': waktuKeKabupatenController.text,
        'lahan_pemukiman': lahanPemukimanController.text,
        'lahan_pertanian': lahanPertanianController.text,
        'lahan_perkebunan': lahanPerkebunanController.text,
        'lahan_perkantoran': lahanPerkantoran.text,
        'lahan_sekolah': lahanSekolahController.text,
        'lahan_olahraga': lahanOlahragaController.text,
        'lahan_pemakaman': lahanPemakamanController.text,
        'lahan_jalan': lahanJalanController.text,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': _auth.currentUser?.uid ?? 'unknown',
      };

      // If data doesn't exist, create it with all required fields
      if (!dataExists.value) {
        dataToSave.addAll({
          'kepala_desa_history': [],
          'struktur_pemerintahan': [],
          'kamituwo': [],
          'perangkat_lainnya': [],
          'bpd': [],
          'lpmd': [],
          'karang_taruna': [],
          'pkk': [],
          'timeline_sejarah': [],
          'created_at': DateTime.now().toIso8601String(),
          'created_by': _auth.currentUser?.uid ?? 'unknown',
        });
        await _database.child('village_profile').set(dataToSave);
        context.showSuccessSnackBar('Data desa berhasil dibuat');
      } else {
        await _database.child('village_profile').update(dataToSave);
        context.showSuccessSnackBar('Data desa berhasil diperbarui');
      }

      // Reload data
      await loadVillageData();
      Get.back();
    } catch (e) {
      context.showErrorSnackBar('Gagal menyimpan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= KEPALA DESA HISTORY MANAGEMENT =================
  Future<void> addKepalaDesaHistory(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentHistory = getDataObjectList('kepala_desa_history');
      final nextNumber = currentHistory.length + 1;

      final newEntry = {
        'nomor': nextNumber,
        'nama': data['nama'],
        'periode': data['periode'],
        'durasi': data['durasi'],
        'isActive': data['isActive'] ?? false,
      };

      currentHistory.add(newEntry);

      await _database
          .child('village_profile/kepala_desa_history')
          .set(currentHistory);
      await loadVillageData();

      context.showSuccessSnackBar('Data kepala desa berhasil ditambahkan');
      Get.back();
    } catch (e) {
      context.showErrorSnackBar('Gagal menambahkan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateKepalaDesaHistory(
    int index,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentHistory = getDataObjectList('kepala_desa_history');
      if (index >= 0 && index < currentHistory.length) {
        currentHistory[index] = {
          'nomor': currentHistory[index]['nomor'],
          'nama': data['nama'],
          'periode': data['periode'],
          'durasi': data['durasi'],
          'isActive': data['isActive'] ?? false,
        };

        await _database
            .child('village_profile/kepala_desa_history')
            .set(currentHistory);
        await loadVillageData();

        context.showSuccessSnackBar('Data kepala desa berhasil diperbarui');
        Get.back();
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memperbarui data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteKepalaDesaHistory(int index, BuildContext context) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentHistory = getDataObjectList('kepala_desa_history');
      if (index >= 0 && index < currentHistory.length) {
        currentHistory.removeAt(index);

        // Renumber
        for (int i = 0; i < currentHistory.length; i++) {
          currentHistory[i]['nomor'] = i + 1;
        }

        await _database
            .child('village_profile/kepala_desa_history')
            .set(currentHistory);
        await loadVillageData();

        context.showSuccessSnackBar('Data kepala desa berhasil dihapus');
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menghapus data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= GENERIC ORGANIZATION MANAGEMENT =================
  Future<void> addOrganizationMember(
    String organizationType,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentMembers = getDataObjectList(organizationType);
      currentMembers.add(data);

      await _database
          .child('village_profile/$organizationType')
          .set(currentMembers);
      await loadVillageData();

      context.showSuccessSnackBar('Anggota berhasil ditambahkan');
      Get.back();
    } catch (e) {
      context.showErrorSnackBar('Gagal menambahkan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrganizationMember(
    String organizationType,
    int index,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentMembers = getDataObjectList(organizationType);
      if (index >= 0 && index < currentMembers.length) {
        currentMembers[index] = data;

        await _database
            .child('village_profile/$organizationType')
            .set(currentMembers);
        await loadVillageData();

        context.showSuccessSnackBar('Data berhasil diperbarui');
        Get.back();
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memperbarui data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrganizationMember(
    String organizationType,
    int index,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentMembers = getDataObjectList(organizationType);
      if (index >= 0 && index < currentMembers.length) {
        currentMembers.removeAt(index);

        await _database
            .child('village_profile/$organizationType')
            .set(currentMembers);
        await loadVillageData();

        context.showSuccessSnackBar('Data berhasil dihapus');
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menghapus data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= TIMELINE SEJARAH MANAGEMENT =================
  Future<void> addTimelineSejarah(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentTimeline = getDataObjectList('timeline_sejarah');
      currentTimeline.add(data);

      await _database
          .child('village_profile/timeline_sejarah')
          .set(currentTimeline);
      await loadVillageData();

      context.showSuccessSnackBar('Timeline sejarah berhasil ditambahkan');
      Get.back();
    } catch (e) {
      context.showErrorSnackBar('Gagal menambahkan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTimelineSejarah(
    int index,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentTimeline = getDataObjectList('timeline_sejarah');
      if (index >= 0 && index < currentTimeline.length) {
        currentTimeline[index] = data;

        await _database
            .child('village_profile/timeline_sejarah')
            .set(currentTimeline);
        await loadVillageData();

        context.showSuccessSnackBar('Timeline sejarah berhasil diperbarui');
        Get.back();
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memperbarui data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTimelineSejarah(int index, BuildContext context) async {
    if (!isAdmin.value) {
      context.showErrorSnackBar('Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      final currentTimeline = getDataObjectList('timeline_sejarah');
      if (index >= 0 && index < currentTimeline.length) {
        currentTimeline.removeAt(index);

        await _database
            .child('village_profile/timeline_sejarah')
            .set(currentTimeline);
        await loadVillageData();

        context.showSuccessSnackBar('Timeline sejarah berhasil dihapus');
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menghapus data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= HELPER: GET DATA =================
  String getData(String key, {String defaultValue = '-'}) {
    return villageData[key]?.toString() ?? defaultValue;
  }

  int getDataInt(String key, {int defaultValue = 0}) {
    final value = villageData[key];
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  List<String> getDataList(String key) {
    final value = villageData[key];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getDataObjectList(String key) {
    final value = villageData[key];
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  // ================= REFRESH DATA =================
  Future<void> refreshData() async {
    await loadVillageData();
  }
}
  