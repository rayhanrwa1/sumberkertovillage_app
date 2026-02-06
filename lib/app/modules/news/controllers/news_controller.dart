import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumberkerto_smart_village/app/data/services/media_compression_service.dart';
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
  final selectedCategory =
      ''.obs; // Changed from selectedTags to single category
  final searchQuery = ''.obs;

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
    fetchCategories();
    fetchNews();

    // Listen to search and filter changes
    ever(searchQuery, (_) => applyFilters());
    ever(selectedCategory, (_) => applyFilters());
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
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  /// Fetch news from Firebase Realtime Database
  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _lastKey = null;
      hasMore.value = true;
      newsList.clear();
    }

    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;

      Query query = _database.child('news').orderByChild('created_at');

      // Pagination
      if (_lastKey != null) {
        query = query.endBefore(_lastKey).limitToLast(_pageSize + 1);
      } else {
        query = query.limitToLast(_pageSize);
      }

      final snapshot = await query.get();

      if (!snapshot.exists) {
        hasMore.value = false;
      } else {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final newsList2 = <NewsModel>[];

        data.forEach((key, value) {
          if (value is Map) {
            final news = NewsModel.fromRealtimeDB(key, value);
            newsList2.add(news);
          }
        });

        // Sort by created_at descending (newest first)
        newsList2.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Handle pagination
        if (_lastKey != null && newsList2.isNotEmpty) {
          newsList2.removeAt(0); // Remove duplicate from previous page
        }

        if (newsList2.length < _pageSize) {
          hasMore.value = false;
        }

        if (newsList2.isNotEmpty) {
          _lastKey = newsList2.last.createdAt.millisecondsSinceEpoch.toString();
          newsList.addAll(newsList2);
          _currentPage++;
        }

        applyFilters();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat berita',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filters to news list
  void applyFilters() {
    var filtered = newsList.toList();

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((news) {
        return news.tags.contains(selectedCategory.value);
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((news) {
        return news.title.toLowerCase().contains(query) ||
            news.description.toLowerCase().contains(query);
      }).toList();
    }

    filteredNews.value = filtered;
  }

  /// Select category filter
  void selectCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = ''; // Deselect if already selected
    } else {
      selectedCategory.value = category;
    }
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

  /// Toggle like
  Future<void> toggleLike(String newsId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        Get.snackbar('Error', 'Silakan login terlebih dahulu');
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
      Get.snackbar(
        'Error',
        'Gagal memperbarui like',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    Get.toNamed('/news-detail', arguments: news);
  }

  /// Navigate to create news
  void createNews() {
    Get.toNamed('/editnews');
  }

  /// Refresh news list
  Future<void> refreshNews() async {
    await fetchCategories();
    await fetchNews(refresh: true);
  }
}
