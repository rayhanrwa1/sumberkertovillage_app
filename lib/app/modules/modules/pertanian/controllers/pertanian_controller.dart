import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PertanianController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  final isLoading = false.obs;
  final isAdmin = false.obs;
  final RxList<Map<String, dynamic>> kelompokTaniList =
      <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>> selectedKelompok =
      Rxn<Map<String, dynamic>>();

  final RxList<Map<String, dynamic>> anggotaList = <Map<String, dynamic>>[].obs;

  final RxMap<String, dynamic> statistik = <String, dynamic>{}.obs;

  // Form Controllers - Info Kelompok
  final formKeyKelompok = GlobalKey<FormState>();
  final kodeKelompokController = TextEditingController();
  final namaKelompokController = TextEditingController();
  final ketuaKelompokController = TextEditingController();
  final penyuluhController = TextEditingController();
  final subsektorController = TextEditingController();
  final komoditasController = TextEditingController();
  final kiosPupukController = TextEditingController();
  final tahunRdkkController = TextEditingController();

  // Form Controllers - Anggota
  final formKeyAnggota = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final namaAnggotaController = TextEditingController();
  final rencanaTanamController = TextEditingController();

  // Kebutuhan Pupuk Controllers
  // UREA
  final ureaM1Controller = TextEditingController();
  final ureaM2Controller = TextEditingController();
  final ureaM3Controller = TextEditingController();

  // NPK
  final npkM1Controller = TextEditingController();
  final npkM2Controller = TextEditingController();
  final npkM3Controller = TextEditingController();

  // NPK Formula
  final npkFormulaM1Controller = TextEditingController();
  final npkFormulaM2Controller = TextEditingController();
  final npkFormulaM3Controller = TextEditingController();

  // Organik
  final organikM1Controller = TextEditingController();
  final organikM2Controller = TextEditingController();
  final organikM3Controller = TextEditingController();

  // ZA
  final zaM1Controller = TextEditingController();
  final zaM2Controller = TextEditingController();
  final zaM3Controller = TextEditingController();

  // Dropdown Options
  final subsektorOptions = ['PERKEBUNAN', 'TANAMAN PANGAN', 'HORTIKULTURA'].obs;

  final komoditasOptions = <String>[].obs;

  final komoditasMap = {
    'PERKEBUNAN': [
      'TEBU RAKYAT',
      'KELAPA SAWIT',
      'KOPI',
      'KAKAO',
      'KARET',
      'KELAPA',
      'JAMBU METE',
      'LADA',
      'VANILI',
      'CENGKEH',
    ],
    'TANAMAN PANGAN': [
      'PADI',
      'JAGUNG',
      'KEDELAI',
      'KACANG TANAH',
      'KACANG HIJAU',
      'UBI KAYU',
      'UBI JALAR',
    ],
    'HORTIKULTURA': [
      'CABAI',
      'BAWANG MERAH',
      'BAWANG PUTIH',
      'TOMAT',
      'KENTANG',
      'KUBIS',
      'SAWI',
      'TERONG',
      'MENTIMUN',
      'KANGKUNG',
    ],
  };

  @override
  void onInit() {
    super.onInit();
    checkAdminRole();
    loadKelompokTani();
    loadStatistik();

    // Update komoditas options when subsektor changes
    subsektorController.addListener(() {
      updateKomoditasOptions(subsektorController.text);
    });

    // Add listeners to pupuk controllers for real-time total update
    _addPupukListeners();
  }

  // Add listeners to all pupuk controllers
  void _addPupukListeners() {
    // UREA
    ureaM1Controller.addListener(_updateTotals);
    ureaM2Controller.addListener(_updateTotals);
    ureaM3Controller.addListener(_updateTotals);

    // NPK
    npkM1Controller.addListener(_updateTotals);
    npkM2Controller.addListener(_updateTotals);
    npkM3Controller.addListener(_updateTotals);

    // NPK Formula
    npkFormulaM1Controller.addListener(_updateTotals);
    npkFormulaM2Controller.addListener(_updateTotals);
    npkFormulaM3Controller.addListener(_updateTotals);

    // Organik
    organikM1Controller.addListener(_updateTotals);
    organikM2Controller.addListener(_updateTotals);
    organikM3Controller.addListener(_updateTotals);

    // ZA
    zaM1Controller.addListener(_updateTotals);
    zaM2Controller.addListener(_updateTotals);
    zaM3Controller.addListener(_updateTotals);
  }

  // Trigger update when any pupuk value changes
  void _updateTotals() {
    update();
  }

  @override
  void onClose() {
    // Dispose all controllers
    kodeKelompokController.dispose();
    namaKelompokController.dispose();
    ketuaKelompokController.dispose();
    penyuluhController.dispose();
    subsektorController.dispose();
    komoditasController.dispose();
    kiosPupukController.dispose();
    tahunRdkkController.dispose();
    nikController.dispose();
    namaAnggotaController.dispose();
    rencanaTanamController.dispose();
    ureaM1Controller.dispose();
    ureaM2Controller.dispose();
    ureaM3Controller.dispose();
    npkM1Controller.dispose();
    npkM2Controller.dispose();
    npkM3Controller.dispose();
    npkFormulaM1Controller.dispose();
    npkFormulaM2Controller.dispose();
    npkFormulaM3Controller.dispose();
    organikM1Controller.dispose();
    organikM2Controller.dispose();
    organikM3Controller.dispose();
    zaM1Controller.dispose();
    zaM2Controller.dispose();
    zaM3Controller.dispose();
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

  // ================= KOMODITAS OPTIONS =================
  void updateKomoditasOptions(String subsektor) {
    komoditasOptions.value = komoditasMap[subsektor] ?? [];
    if (komoditasOptions.isNotEmpty) {
      komoditasController.text = komoditasOptions.first;
    }
  }

  // ================= LOAD KELOMPOK TANI =================
  Future<void> loadKelompokTani() async {
    try {
      isLoading.value = true;
      final snapshot = await _database.child('pertanian/kelompok_tani').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        kelompokTaniList.value = data.entries.map((entry) {
          final kelompokData = Map<String, dynamic>.from(
            entry.value['info_kelompok'] ?? {},
          );
          kelompokData['id'] = entry.key;
          return kelompokData;
        }).toList();
      } else {
        kelompokTaniList.value = [];
      }
    } catch (e) {
      print('Error loading kelompok tani: $e');
      Get.snackbar('Error', 'Gagal memuat data kelompok tani');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOAD ANGGOTA =================
  Future<void> loadAnggota(String kelompokId) async {
    try {
      isLoading.value = true;
      final snapshot = await _database
          .child('pertanian/kelompok_tani/$kelompokId/anggota')
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        anggotaList.value = data.entries.map((entry) {
          final anggotaData = Map<String, dynamic>.from(entry.value);
          anggotaData['id'] = entry.key;
          return anggotaData;
        }).toList();

        // Sort by nama
        anggotaList.sort(
          (a, b) => (a['nama'] ?? '').toString().compareTo(
            (b['nama'] ?? '').toString(),
          ),
        );
      } else {
        anggotaList.value = [];
      }
    } catch (e) {
      print('Error loading anggota: $e');
      Get.snackbar('Error', 'Gagal memuat data anggota');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOAD STATISTIK =================
  Future<void> loadStatistik() async {
    try {
      final snapshot = await _database.child('pertanian/statistik').get();
      if (snapshot.exists) {
        statistik.value = Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Error loading statistik: $e');
    }
  }

  // ================= CREATE KELOMPOK TANI =================
  Future<void> createKelompokTani(BuildContext context) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    if (!formKeyKelompok.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final kelompokRef = _database.child('pertanian/kelompok_tani').push();
      final kelompokId = kelompokRef.key!;

      final dataToSave = {
        'info_kelompok': {
          'kode_kelompok': kodeKelompokController.text,
          'nama_kelompok': namaKelompokController.text,
          'ketua_kelompok': ketuaKelompokController.text,
          'penyuluh_pendamping': penyuluhController.text,
          'subsektor': subsektorController.text,
          'komoditas': komoditasController.text,
          'kios_pupuk': kiosPupukController.text,
          'tahun_rdkk': tahunRdkkController.text,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
          'created_by': _auth.currentUser?.uid ?? 'unknown',
        },
        'anggota': {},
      };

      await kelompokRef.set(dataToSave);
      await updateStatistik();
      await loadKelompokTani();

      Get.back();
      Get.snackbar('Sukses', 'Kelompok tani berhasil ditambahkan');
      clearKelompokForm();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan kelompok tani: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE KELOMPOK TANI =================
  Future<void> updateKelompokTani(
    String kelompokId,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    if (!formKeyKelompok.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final dataToUpdate = {
        'kode_kelompok': kodeKelompokController.text,
        'nama_kelompok': namaKelompokController.text,
        'ketua_kelompok': ketuaKelompokController.text,
        'penyuluh_pendamping': penyuluhController.text,
        'subsektor': subsektorController.text,
        'komoditas': komoditasController.text,
        'kios_pupuk': kiosPupukController.text,
        'tahun_rdkk': tahunRdkkController.text,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': _auth.currentUser?.uid ?? 'unknown',
      };

      await _database
          .child('pertanian/kelompok_tani/$kelompokId/info_kelompok')
          .update(dataToUpdate);

      await loadKelompokTani();
      Get.back();
      Get.snackbar('Sukses', 'Kelompok tani berhasil diperbarui');
      clearKelompokForm();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui kelompok tani: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE KELOMPOK TANI =================
  Future<void> deleteKelompokTani(String kelompokId) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      await _database.child('pertanian/kelompok_tani/$kelompokId').remove();
      await updateStatistik();
      await loadKelompokTani();

      Get.snackbar('Sukses', 'Kelompok tani berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus kelompok tani: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= CREATE ANGGOTA =================
  Future<void> createAnggota(String kelompokId, BuildContext context) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    if (!formKeyAnggota.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final anggotaRef = _database
          .child('pertanian/kelompok_tani/$kelompokId/anggota')
          .push();

      final int ureaTotal =
          (int.tryParse(ureaM1Controller.text) ?? 0) +
          (int.tryParse(ureaM2Controller.text) ?? 0) +
          (int.tryParse(ureaM3Controller.text) ?? 0);

      final int npkTotal =
          (int.tryParse(npkM1Controller.text) ?? 0) +
          (int.tryParse(npkM2Controller.text) ?? 0) +
          (int.tryParse(npkM3Controller.text) ?? 0);

      final int npkFormulaTotal =
          (int.tryParse(npkFormulaM1Controller.text) ?? 0) +
          (int.tryParse(npkFormulaM2Controller.text) ?? 0) +
          (int.tryParse(npkFormulaM3Controller.text) ?? 0);

      final int organikTotal =
          (int.tryParse(organikM1Controller.text) ?? 0) +
          (int.tryParse(organikM2Controller.text) ?? 0) +
          (int.tryParse(organikM3Controller.text) ?? 0);

      final int zaTotal =
          (int.tryParse(zaM1Controller.text) ?? 0) +
          (int.tryParse(zaM2Controller.text) ?? 0) +
          (int.tryParse(zaM3Controller.text) ?? 0);

      final dataToSave = {
        'nik': nikController.text,
        'nama': namaAnggotaController.text,
        'rencana_tanam_ha': double.tryParse(rencanaTanamController.text) ?? 0.0,
        'kebutuhan_pupuk': {
          'urea': {
            'mt1': int.tryParse(ureaM1Controller.text) ?? 0,
            'mt2': int.tryParse(ureaM2Controller.text) ?? 0,
            'mt3': int.tryParse(ureaM3Controller.text) ?? 0,
            'total': ureaTotal,
          },
          'npk': {
            'mt1': int.tryParse(npkM1Controller.text) ?? 0,
            'mt2': int.tryParse(npkM2Controller.text) ?? 0,
            'mt3': int.tryParse(npkM3Controller.text) ?? 0,
            'total': npkTotal,
          },
          'npk_formula': {
            'mt1': int.tryParse(npkFormulaM1Controller.text) ?? 0,
            'mt2': int.tryParse(npkFormulaM2Controller.text) ?? 0,
            'mt3': int.tryParse(npkFormulaM3Controller.text) ?? 0,
            'total': npkFormulaTotal,
          },
          'organik': {
            'mt1': int.tryParse(organikM1Controller.text) ?? 0,
            'mt2': int.tryParse(organikM2Controller.text) ?? 0,
            'mt3': int.tryParse(organikM3Controller.text) ?? 0,
            'total': organikTotal,
          },
          'za': {
            'mt1': int.tryParse(zaM1Controller.text) ?? 0,
            'mt2': int.tryParse(zaM2Controller.text) ?? 0,
            'mt3': int.tryParse(zaM3Controller.text) ?? 0,
            'total': zaTotal,
          },
        },
        'created_at': DateTime.now().toIso8601String(),
        'created_by': _auth.currentUser?.uid ?? 'unknown',
      };

      await anggotaRef.set(dataToSave);
      await updateStatistik();
      await loadAnggota(kelompokId);

      Get.back();
      Get.snackbar('Sukses', 'Anggota berhasil ditambahkan');
      clearAnggotaForm();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan anggota: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE ANGGOTA =================
  Future<void> updateAnggota(
    String kelompokId,
    String anggotaId,
    BuildContext context,
  ) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    if (!formKeyAnggota.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final int ureaTotal =
          (int.tryParse(ureaM1Controller.text) ?? 0) +
          (int.tryParse(ureaM2Controller.text) ?? 0) +
          (int.tryParse(ureaM3Controller.text) ?? 0);

      final int npkTotal =
          (int.tryParse(npkM1Controller.text) ?? 0) +
          (int.tryParse(npkM2Controller.text) ?? 0) +
          (int.tryParse(npkM3Controller.text) ?? 0);

      final int npkFormulaTotal =
          (int.tryParse(npkFormulaM1Controller.text) ?? 0) +
          (int.tryParse(npkFormulaM2Controller.text) ?? 0) +
          (int.tryParse(npkFormulaM3Controller.text) ?? 0);

      final int organikTotal =
          (int.tryParse(organikM1Controller.text) ?? 0) +
          (int.tryParse(organikM2Controller.text) ?? 0) +
          (int.tryParse(organikM3Controller.text) ?? 0);

      final int zaTotal =
          (int.tryParse(zaM1Controller.text) ?? 0) +
          (int.tryParse(zaM2Controller.text) ?? 0) +
          (int.tryParse(zaM3Controller.text) ?? 0);

      final dataToUpdate = {
        'nik': nikController.text,
        'nama': namaAnggotaController.text,
        'rencana_tanam_ha': double.tryParse(rencanaTanamController.text) ?? 0.0,
        'kebutuhan_pupuk': {
          'urea': {
            'mt1': int.tryParse(ureaM1Controller.text) ?? 0,
            'mt2': int.tryParse(ureaM2Controller.text) ?? 0,
            'mt3': int.tryParse(ureaM3Controller.text) ?? 0,
            'total': ureaTotal,
          },
          'npk': {
            'mt1': int.tryParse(npkM1Controller.text) ?? 0,
            'mt2': int.tryParse(npkM2Controller.text) ?? 0,
            'mt3': int.tryParse(npkM3Controller.text) ?? 0,
            'total': npkTotal,
          },
          'npk_formula': {
            'mt1': int.tryParse(npkFormulaM1Controller.text) ?? 0,
            'mt2': int.tryParse(npkFormulaM2Controller.text) ?? 0,
            'mt3': int.tryParse(npkFormulaM3Controller.text) ?? 0,
            'total': npkFormulaTotal,
          },
          'organik': {
            'mt1': int.tryParse(organikM1Controller.text) ?? 0,
            'mt2': int.tryParse(organikM2Controller.text) ?? 0,
            'mt3': int.tryParse(organikM3Controller.text) ?? 0,
            'total': organikTotal,
          },
          'za': {
            'mt1': int.tryParse(zaM1Controller.text) ?? 0,
            'mt2': int.tryParse(zaM2Controller.text) ?? 0,
            'mt3': int.tryParse(zaM3Controller.text) ?? 0,
            'total': zaTotal,
          },
        },
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': _auth.currentUser?.uid ?? 'unknown',
      };

      await _database
          .child('pertanian/kelompok_tani/$kelompokId/anggota/$anggotaId')
          .update(dataToUpdate);

      await updateStatistik();
      await loadAnggota(kelompokId);

      Get.back();
      Get.snackbar('Sukses', 'Data anggota berhasil diperbarui');
      clearAnggotaForm();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data anggota: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE ANGGOTA =================
  Future<void> deleteAnggota(String kelompokId, String anggotaId) async {
    if (!isAdmin.value) {
      Get.snackbar('Error', 'Anda tidak memiliki akses admin');
      return;
    }

    try {
      isLoading.value = true;

      await _database
          .child('pertanian/kelompok_tani/$kelompokId/anggota/$anggotaId')
          .remove();

      await updateStatistik();
      await loadAnggota(kelompokId);

      Get.snackbar('Sukses', 'Anggota berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus anggota: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE STATISTIK =================
  Future<void> updateStatistik() async {
    try {
      final snapshot = await _database.child('pertanian/kelompok_tani').get();

      if (!snapshot.exists) {
        await _database.child('pertanian/statistik').set({
          'total_kelompok': 0,
          'total_anggota': 0,
          'total_luas_tanam': 0.0,
          'total_kebutuhan_pupuk': {
            'urea': 0,
            'npk': 0,
            'npk_formula': 0,
            'organik': 0,
            'za': 0,
          },
        });
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      int totalKelompok = data.length;
      int totalAnggota = 0;
      double totalLuasTanam = 0.0;
      int totalUrea = 0;
      int totalNpk = 0;
      int totalNpkFormula = 0;
      int totalOrganik = 0;
      int totalZa = 0;

      for (var kelompok in data.values) {
        if (kelompok['anggota'] != null) {
          final anggotaData = Map<String, dynamic>.from(
            kelompok['anggota'] as Map,
          );

          totalAnggota += anggotaData.length;

          for (var anggota in anggotaData.values) {
            final anggotaMap = Map<String, dynamic>.from(anggota as Map);

            // Luas tanam
            totalLuasTanam +=
                (anggotaMap['rencana_tanam_ha'] as num?)?.toDouble() ?? 0.0;

            // Kebutuhan pupuk
            if (anggotaMap['kebutuhan_pupuk'] != null) {
              final pupuk = Map<String, dynamic>.from(
                anggotaMap['kebutuhan_pupuk'] as Map,
              );

              totalUrea += (pupuk['urea'] as Map?)?['total'] as int? ?? 0;

              totalNpk += (pupuk['npk'] as Map?)?['total'] as int? ?? 0;

              totalNpkFormula +=
                  (pupuk['npk_formula'] as Map?)?['total'] as int? ?? 0;

              totalOrganik += (pupuk['organik'] as Map?)?['total'] as int? ?? 0;

              totalZa += (pupuk['za'] as Map?)?['total'] as int? ?? 0;
            }
          }
        }
      }

      await _database.child('pertanian/statistik').set({
        'total_kelompok': totalKelompok,
        'total_anggota': totalAnggota,
        'total_luas_tanam': totalLuasTanam,
        'total_kebutuhan_pupuk': {
          'urea': totalUrea,
          'npk': totalNpk,
          'npk_formula': totalNpkFormula,
          'organik': totalOrganik,
          'za': totalZa,
        },
        'updated_at': DateTime.now().toIso8601String(),
      });

      await loadStatistik();
    } catch (e) {
      print('Error updating statistik: $e');
    }
  }

  // ================= POPULATE FORM KELOMPOK =================
  void populateKelompokForm(Map<String, dynamic> kelompok) {
    kodeKelompokController.text = kelompok['kode_kelompok'] ?? '';
    namaKelompokController.text = kelompok['nama_kelompok'] ?? '';
    ketuaKelompokController.text = kelompok['ketua_kelompok'] ?? '';
    penyuluhController.text = kelompok['penyuluh_pendamping'] ?? '';
    subsektorController.text = kelompok['subsektor'] ?? '';
    komoditasController.text = kelompok['komoditas'] ?? '';
    kiosPupukController.text = kelompok['kios_pupuk'] ?? '';
    tahunRdkkController.text = kelompok['tahun_rdkk'] ?? '';
  }

  // ================= POPULATE FORM ANGGOTA =================
  void populateAnggotaForm(Map<String, dynamic> anggota) {
    nikController.text = anggota['nik'] ?? '';
    namaAnggotaController.text = anggota['nama'] ?? '';
    rencanaTanamController.text = anggota['rencana_tanam_ha']?.toString() ?? '';

    if (anggota['kebutuhan_pupuk'] != null) {
      final pupuk = anggota['kebutuhan_pupuk'];

      // UREA
      ureaM1Controller.text = pupuk['urea']?['mt1']?.toString() ?? '0';
      ureaM2Controller.text = pupuk['urea']?['mt2']?.toString() ?? '0';
      ureaM3Controller.text = pupuk['urea']?['mt3']?.toString() ?? '0';

      // NPK
      npkM1Controller.text = pupuk['npk']?['mt1']?.toString() ?? '0';
      npkM2Controller.text = pupuk['npk']?['mt2']?.toString() ?? '0';
      npkM3Controller.text = pupuk['npk']?['mt3']?.toString() ?? '0';

      // NPK Formula
      npkFormulaM1Controller.text =
          pupuk['npk_formula']?['mt1']?.toString() ?? '0';
      npkFormulaM2Controller.text =
          pupuk['npk_formula']?['mt2']?.toString() ?? '0';
      npkFormulaM3Controller.text =
          pupuk['npk_formula']?['mt3']?.toString() ?? '0';

      // Organik
      organikM1Controller.text = pupuk['organik']?['mt1']?.toString() ?? '0';
      organikM2Controller.text = pupuk['organik']?['mt2']?.toString() ?? '0';
      organikM3Controller.text = pupuk['organik']?['mt3']?.toString() ?? '0';

      // ZA
      zaM1Controller.text = pupuk['za']?['mt1']?.toString() ?? '0';
      zaM2Controller.text = pupuk['za']?['mt2']?.toString() ?? '0';
      zaM3Controller.text = pupuk['za']?['mt3']?.toString() ?? '0';
    }
  }

  // ================= CLEAR FORMS =================
  void clearKelompokForm() {
    kodeKelompokController.clear();
    namaKelompokController.clear();
    ketuaKelompokController.clear();
    penyuluhController.clear();
    subsektorController.clear();
    komoditasController.clear();
    kiosPupukController.clear();
    tahunRdkkController.clear();
  }

  void clearAnggotaForm() {
    nikController.clear();
    namaAnggotaController.clear();
    rencanaTanamController.clear();
    ureaM1Controller.clear();
    ureaM2Controller.clear();
    ureaM3Controller.clear();
    npkM1Controller.clear();
    npkM2Controller.clear();
    npkM3Controller.clear();
    npkFormulaM1Controller.clear();
    npkFormulaM2Controller.clear();
    npkFormulaM3Controller.clear();
    organikM1Controller.clear();
    organikM2Controller.clear();
    organikM3Controller.clear();
    zaM1Controller.clear();
    zaM2Controller.clear();
    zaM3Controller.clear();
  }

  // ================= REFRESH =================
  Future<void> refreshData() async {
    await loadKelompokTani();
    await loadStatistik();
  }
}
