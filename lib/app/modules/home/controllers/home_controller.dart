import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  final totalPenduduk = 0.obs;
  final isProfileComplete = false.obs;
  final isAdmin = false.obs;

  // Village Profile Data
  final villageProfile = <String, dynamic>{}.obs;
  final isLoadingVillageData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPenduduk();
    checkProfileComplete();
    checkAdminRole();
    loadVillageProfile();
  }

  // ================= LOAD TOTAL PENDUDUK =================
  Future<void> loadPenduduk() async {
    try {
      final snapshot = await _database.child('stats/total_penduduk').get();

      totalPenduduk.value = snapshot.exists
          ? int.parse(snapshot.value.toString())
          : 0;
    } catch (e) {
      print('Error loading penduduk: $e');
    }
  }

  // ================= CHECK USER PROFILE COMPLETE =================
  void checkProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) {
      isProfileComplete.value = false;
      return;
    }

    try {
      final snapshot = await _database.child('profile/${user.uid}').get();

      if (!snapshot.exists) {
        isProfileComplete.value = false;
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Check required fields
      isProfileComplete.value =
          data['nik']?.toString().isNotEmpty == true &&
          data['address']?.toString().isNotEmpty == true &&
          data['phone']?.toString().isNotEmpty == true &&
          data['gender']?.toString().isNotEmpty == true &&
          data['tanggal_lahir']?.toString().isNotEmpty == true &&
          data['dusun']?.toString().isNotEmpty == true &&
          data['rw']?.toString().isNotEmpty == true &&
          data['rt']?.toString().isNotEmpty == true;
    } catch (e) {
      print('Error checking profile: $e');
      isProfileComplete.value = false;
    }
  }

  // ================= CHECK ADMIN ROLE =================
  void checkAdminRole() async {
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

  // ================= LOAD VILLAGE PROFILE =================
  Future<void> loadVillageProfile() async {
    try {
      isLoadingVillageData.value = true;

      final snapshot = await _database.child('village_profile').get();

      if (snapshot.exists) {
        villageProfile.value = Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        // Set default data sesuai PDF Profil Desa
        villageProfile.value = {
          'nama_desa': 'Sumberkerto',
          'kecamatan': 'Pagak',
          'kabupaten': 'Malang',
          'provinsi': 'Jawa Timur',
          'ketinggian': '470 m dpl',
          'luas_wilayah': '1.092.500 Ha',
          'jumlah_dusun': 3,
          'nama_dusun': ['Sumberwader', 'Krajan', 'Kaligading'],
          'jumlah_rw': 6,
          'jumlah_rt': 20,
          'total_penduduk': 4446,
          'laki_laki': 2161,
          'perempuan': 2284,
          'total_kk': 1215,
          'kepala_desa': 'Ir. Hosen',
          'tahun_menjabat': '2014',
          'visi':
              'Terwujudnya Desa Sumberkerto yang maju, mandiri, dan sejahtera',
          'misi': [
            'Meningkatkan kualitas sumber daya manusia',
            'Mengembangkan potensi pertanian dan perkebunan',
            'Meningkatkan infrastruktur dan pelayanan publik',
            'Memberdayakan ekonomi masyarakat',
          ],
          'batas_utara': 'Desa Pagak',
          'batas_selatan': 'Desa Pandanrejo',
          'batas_barat': 'Desa Sempol',
          'batas_timur': 'Desa Pringgondani Kecamatan Bantur',
          'jarak_kecamatan': '6 km',
          'waktu_ke_kecamatan': '60 menit',
          'jarak_kabupaten': '54 km',
          'waktu_ke_kabupaten': '6 jam',
          'lahan_pemukiman': '99.80 Ha',
          'lahan_pertanian': '12 Ha',
          'lahan_perkebunan': '781.1 Ha',
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      print('Error loading village profile: $e');
    } finally {
      isLoadingVillageData.value = false;
    }
  }

  // ================= UPDATE VILLAGE PROFILE (ADMIN ONLY) =================
  Future<bool> updateVillageProfile(Map<String, dynamic> data) async {
    if (!isAdmin.value) {
      return false;
    }

    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      data['updated_by'] = _auth.currentUser?.uid ?? 'unknown';

      await _database.child('village_profile').update(data);

      // Reload data
      await loadVillageProfile();

      return true;
    } catch (e) {
      print('Error updating village profile: $e');
      return false;
    }
  }

  // ================= REFRESH ALL DATA =================
  Future<void> refreshAllData() async {
    await Future.wait([
      loadPenduduk(),
      checkProfileComplete(),
      loadVillageProfile(),
    ] as Iterable<Future>);
  }

  // ================= HELPER: GET VILLAGE INFO =================
  String getVillageInfo(String key, {String defaultValue = '-'}) {
    return villageProfile[key]?.toString() ?? defaultValue;
  }

  int getVillageInfoInt(String key, {int defaultValue = 0}) {
    final value = villageProfile[key];
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  List<String> getVillageInfoList(String key) {
    final value = villageProfile[key];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
