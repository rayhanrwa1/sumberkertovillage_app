import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/data/models/news_model.dart';

class NewsviewController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Terima news dari arguments
  late final NewsModel news;

  // Observable untuk nama creator
  final creatorName = 'Loading...'.obs;
  final isLoadingCreator = true.obs;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get news dari arguments
    if (Get.arguments != null && Get.arguments is NewsModel) {
      news = Get.arguments as NewsModel;
      // Fetch creator name dari database
      fetchCreatorName();
    } else {
      // Jika tidak ada arguments, kembali ke halaman sebelumnya
      Get.back();
    }
  }

  /// Fetch creator name dari database users
  Future<void> fetchCreatorName() async {
    try {
      isLoadingCreator.value = true;

      if (news.userId.isEmpty) {
        creatorName.value = 'Anonymous';
        isLoadingCreator.value = false;
        return;
      }

      // Fetch name dari users/{userId}/name
      final snapshot = await _database.child('users/${news.userId}/name').get();

      if (snapshot.exists && snapshot.value != null) {
        creatorName.value = snapshot.value.toString();
      } else {
        // Jika tidak ada name, coba ambil dari created_by
        creatorName.value = news.createdBy.isNotEmpty
            ? news.createdBy
            : 'Anonymous';
      }
    } catch (e) {
      print('Error fetching creator name: $e');
      creatorName.value = news.createdBy.isNotEmpty
          ? news.createdBy
          : 'Anonymous';
    } finally {
      isLoadingCreator.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
