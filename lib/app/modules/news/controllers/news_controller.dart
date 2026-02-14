import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumberkerto_smart_village/app/data/services/media_compression_service.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import '../../../data/models/news_model.dart';

class NewsController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage2 = GetStorage();

  final ImagePicker _picker = ImagePicker();
  final isCreateDisabled = false.obs;

  // Observable lists
  final newsList = <NewsModel>[].obs;
  final filteredNews = <NewsModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  // Filter options
  final selectedCategory = ''.obs;
  final searchQuery = ''.obs;
  final selectedContentType = 'all'.obs; // 🆕 TAMBAHAN BARU: Filter tipe konten

  // Available categories - Top 5 from database
  final availableCategories = <String>[].obs;

  // Pagination
  int _currentPage = 0;
  final hasMore = true.obs;
  static const int _pageSize = 10;
  String? _lastKey;

  @override
  void onInit() {
    super.onInit();
    print('NewsController onInit');
    fetchCategories();
    fetchNews();

    // Listen to search and filter changes
    ever(searchQuery, (_) => applyFilters());
    ever(selectedCategory, (_) => applyFilters());
    ever(selectedContentType, (_) => applyFilters()); // 🆕 TAMBAHAN BARU
  }

  @override
  void onClose() {
    MediaCompressionService.cleanupTemporary();
    super.onClose();
  }

  /// Get current user ID from GetStorage
  String? get _currentUserId {
    return _storage2.read('userId') ?? _auth.currentUser?.uid;
  }

  /// Fetch top 5 categories from database
  Future<void> fetchCategories() async {
    try {
      print('Fetching categories...');
      final snapshot = await _database.child('news').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final Map<String, int> categoryCount = {};

        // Count category occurrences
        data.forEach((key, value) {
          if (value is Map && value['category'] != null) {
            final category = value['category'] as String;
            categoryCount[category] = (categoryCount[category] ?? 0) + 1;
          }
        });

        // Sort by count and take top 5
        final sortedCategories = categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        availableCategories.value = sortedCategories
            .take(5)
            .map((e) => e.key)
            .toList();

        print('Categories loaded: ${availableCategories.length}');
      } else {
        print('No news data found in database');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  /// Fetch news from Firebase Realtime Database
  Future<void> fetchNews({bool refresh = false, BuildContext? context}) async {
    if (refresh) {
      _currentPage = 0;
      _lastKey = null;
      hasMore.value = true;
      newsList.clear();
      print('Refreshing news list...');
    }

    if (!hasMore.value || isLoading.value) {
      print(
        'Skipping fetch: hasMore=${hasMore.value}, isLoading=${isLoading.value}',
      );
      return;
    }

    try {
      isLoading.value = true;
      print('Fetching news from Firebase...');

      final snapshot = await _database.child('news').get();

      if (!snapshot.exists) {
        print('No news found in database');
        hasMore.value = false;
        filteredNews.value = [];
      } else {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Found ${data.length} news items in database');

        final newsListTemp = <NewsModel>[];
        int successCount = 0;
        int errorCount = 0;

        data.forEach((key, value) {
          if (value is Map) {
            try {
              final news = NewsModel.fromRealtimeDB(key, value);
              newsListTemp.add(news);
              successCount++;
            } catch (e) {
              print('Error parsing news $key: $e');
              print('News data: $value');
              errorCount++;
            }
          }
        });

        print('Successfully parsed: $successCount, Errors: $errorCount');

        // Sort by created_at descending (newest first)
        newsListTemp.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        newsList.value = newsListTemp;
        hasMore.value = false;

        print('News list updated: ${newsList.length} items');

        applyFilters();
      }
    } catch (e) {
      print('Error fetching news: $e');
      print('Stack trace: ${StackTrace.current}');
      if (context != null) {
        context.showErrorSnackBar('Gagal memuat berita: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
      print('Fetch news completed. Loading: ${isLoading.value}');
    }
  }

  /// 🆕 FUNGSI BARU: Cek tipe konten dari NewsModel
  String _getContentType(NewsModel news) {
    final hasVideo = news.videoUrl != null && news.videoUrl!.isNotEmpty;
    final hasImage =
        (news.bannerImage != null && news.bannerImage!.isNotEmpty) ||
        (news.images.isNotEmpty && news.images.first.isNotEmpty);

    if (hasVideo) return 'video';
    if (hasImage) return 'photo';
    return 'text';
  }

  /// Apply filters to news list - 🔄 DIUPDATE dengan filter content type
  void applyFilters() {
    print('Applying filters - Total news: ${newsList.length}');
    var filtered = newsList.toList();

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      print('Filtering by category: ${selectedCategory.value}');
      filtered = filtered.where((news) {
        return news.tags.contains(selectedCategory.value);
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      print('Filtering by search: ${searchQuery.value}');
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((news) {
        return news.title.toLowerCase().contains(query) ||
            news.description.toLowerCase().contains(query);
      }).toList();
    }

    // 🆕 TAMBAHAN BARU: Apply content type filter
    if (selectedContentType.value != 'all') {
      print('Filtering by content type: ${selectedContentType.value}');
      filtered = filtered.where((news) {
        final contentType = _getContentType(news);
        return contentType == selectedContentType.value;
      }).toList();
    }

    filteredNews.value = filtered;
    print('Filtered news count: ${filteredNews.length}');
    print('Content type filter: ${selectedContentType.value}');
  }

  /// Select category filter
  void selectCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = ''; // Deselect if already selected
    } else {
      selectedCategory.value = category;
    }
  }

  /// 🆕 FUNGSI BARU: Select content type filter
  void selectContentType(String type) {
    print('Selected content type: $type');
    selectedContentType.value = type;
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Increment view count
  Future<void> incrementViewCount(String newsId) async {
    try {
      final newsRef = _database.child('news/$newsId');
      final snapshot = await newsRef.child('view_count').get();

      int currentCount = 0;
      if (snapshot.exists) {
        currentCount = snapshot.value as int? ?? 0;
      }

      await newsRef.update({'view_count': currentCount + 1});

      // Update local list
      final index = newsList.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        newsList[index] = newsList[index].copyWith(viewCount: currentCount + 1);
        applyFilters();
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  void editNews(NewsModel news) {
    Get.toNamed('/editnews', arguments: news);
  }

  /// Toggle like
  Future<void> toggleLike(String newsId, BuildContext context) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        context.showErrorSnackBar('Silakan login terlebih dahulu');
        return;
      }

      final likeRef = _database.child('news/$newsId/likes/$userId');
      final newsRef = _database.child('news/$newsId');

      final likeSnapshot = await likeRef.get();
      final countSnapshot = await newsRef.child('like_count').get();

      int currentCount = 0;
      if (countSnapshot.exists) {
        currentCount = countSnapshot.value as int? ?? 0;
      }

      if (likeSnapshot.exists) {
        // Unlike
        await likeRef.remove();
        await newsRef.update({'like_count': currentCount - 1});
      } else {
        // Like
        await likeRef.set({'liked_at': DateTime.now().millisecondsSinceEpoch});
        await newsRef.update({'like_count': currentCount + 1});
      }

      // Update local list
      final index = newsList.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        final newCount = likeSnapshot.exists
            ? currentCount - 1
            : currentCount + 1;
        newsList[index] = newsList[index].copyWith(likeCount: newCount);
        applyFilters();
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memperbarui like');
    }
  }

  /// Check if user liked a news
  Future<bool> isLiked(String newsId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      final likeSnapshot = await _database
          .child('news/$newsId/likes/$userId')
          .get();

      return likeSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Navigate to news detail
  void openNewsDetail(NewsModel news) {
    incrementViewCount(news.id);
    // Ubah dari /news-detail ke /newsview
    Get.toNamed('/newsview', arguments: news);
  }

  /// Navigate to create news
  void createNews() {
    Get.toNamed('/editnews');
  }

  /// Refresh news list
  Future<void> refreshNews({BuildContext? context}) async {
    await fetchCategories();
    await fetchNews(refresh: true, context: context);
  }

  /// Check if current user can delete this news
  bool canDeleteNews(NewsModel news) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;

    // User can delete if they created the news
    return news.userId == currentUserId;
  }

  /// Delete news
  Future<void> deleteNews(NewsModel news, BuildContext context) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
        ),
        barrierDismissible: false,
      );

      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        Get.back(); // Close loading
        context.showErrorSnackBar('Silakan login terlebih dahulu');
        return;
      }

      // Verify user owns this news
      if (news.userId != currentUserId) {
        Get.back(); // Close loading
        context.showErrorSnackBar(
          'Anda tidak memiliki izin untuk menghapus berita ini',
        );
        return;
      }

      print('Deleting news: ${news.id}');

      // Track deletion results
      List<String> deletionErrors = [];

      // 1. Delete images from Firebase Storage if any
      if (news.images.isNotEmpty) {
        for (final imageUrl in news.images) {
          try {
            if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
              final ref = _storage.refFromURL(imageUrl);
              await ref.delete();
              print('✓ Deleted image: $imageUrl');
            }
          } catch (e) {
            print('✗ Error deleting image $imageUrl: $e');
            deletionErrors.add('Image: ${e.toString()}');
          }
        }
      }

      // 2. Delete banner image if exists
      if (news.bannerImage != null &&
          news.bannerImage!.isNotEmpty &&
          news.bannerImage!.contains('firebase')) {
        try {
          final ref = _storage.refFromURL(news.bannerImage!);
          await ref.delete();
          print('✓ Deleted banner image: ${news.bannerImage}');
        } catch (e) {
          print('✗ Error deleting banner image: $e');
          deletionErrors.add('Banner: ${e.toString()}');
        }
      }

      // 3. Delete video file if exists (🆕 TAMBAHAN BARU)
      if (news.videoUrl != null &&
          news.videoUrl!.isNotEmpty &&
          news.videoUrl!.contains('firebase')) {
        try {
          final ref = _storage.refFromURL(news.videoUrl!);
          await ref.delete();
          print('✓ Deleted video: ${news.videoUrl}');
        } catch (e) {
          print('✗ Error deleting video: $e');
          deletionErrors.add('Video: ${e.toString()}');
        }
      }

      // 4. Delete video thumbnail if exists
      if (news.videoThumbnail != null &&
          news.videoThumbnail!.isNotEmpty &&
          news.videoThumbnail!.contains('firebase')) {
        try {
          final ref = _storage.refFromURL(news.videoThumbnail!);
          await ref.delete();
          print('✓ Deleted video thumbnail: ${news.videoThumbnail}');
        } catch (e) {
          print('✗ Error deleting video thumbnail: $e');
          deletionErrors.add('Thumbnail: ${e.toString()}');
        }
      }

      // 5. Delete news from Firebase Realtime Database
      await _database.child('news/${news.id}').remove();
      print('✓ Deleted news from database: ${news.id}');

      // 6. Remove from local list
      newsList.removeWhere((item) => item.id == news.id);

      // 7. Reapply filters to update UI
      applyFilters();

      // Close loading dialog
      Get.back();

      // Show success message with warning if there were storage errors
      if (deletionErrors.isEmpty) {
        context.showSuccessSnackBar('Berita berhasil dihapus');
      } else {
        context.showSuccessSnackBar(
          'Berita dihapus, namun beberapa file gagal dihapus dari storage',
        );
        print('Storage deletion errors: ${deletionErrors.join(", ")}');
      }

      // Refresh categories after delete
      await fetchCategories();
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) Get.back();

      print('Error deleting news: $e');
      print('Stack trace: ${StackTrace.current}');

      // Show error message
      context.showErrorSnackBar('Gagal menghapus berita: ${e.toString()}');
    }
  }
}
