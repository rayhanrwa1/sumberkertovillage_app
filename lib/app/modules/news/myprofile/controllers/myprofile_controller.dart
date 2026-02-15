import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sumberkerto_smart_village/app/data/models/news_model.dart';

class MyprofileController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // User data
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhotoUrl = ''.obs;
  final userRole = ''.obs;

  // User's posts
  final userPosts = <NewsModel>[].obs;
  final filteredPosts = <NewsModel>[].obs;

  // Stats
  final totalPosts = 0.obs;
  final totalViews = 0.obs;
  final totalLikes = 0.obs;

  // Loading states
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; // all, video, photo

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchUserPosts();

    // Listen to filter changes
    ever(selectedFilter, (_) => applyFilter());
  }

  /// Get current user ID
  String? get _currentUserId {
    return _storage.read('userId') ?? _auth.currentUser?.uid;
  }

  /// Fetch user data from database (users/uid/name path)
  Future<void> fetchUserData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      print('🔍 Starting fetch for userId: $userId');

      // Try fetching from users/uid first (for name, email, role)
      final userSnapshot = await _database.child('users/$userId').get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        userName.value = userData['name'] ?? 'User';
        userEmail.value = userData['email'] ?? _auth.currentUser?.email ?? '';
        userRole.value = userData['role'] ?? 'user';

        print('✅ User data loaded from users/$userId: ${userName.value}');
      } else {
        // Fallback to profile path for basic info
        final profileSnapshot = await _database.child('profile/$userId').get();

        if (profileSnapshot.exists) {
          final profileData = profileSnapshot.value as Map<dynamic, dynamic>;

          userName.value = profileData['name'] ?? 'User';
          userEmail.value =
              profileData['email'] ?? _auth.currentUser?.email ?? '';
          userRole.value = profileData['role'] ?? 'user';

          print('✅ User data loaded from profile/$userId: ${userName.value}');
        }
      }

      // Fetch photo from profile/uid/photo_profile (PRIORITY)
      print('📸 Trying to fetch photo from profile/$userId/photo_profile');
      final photoSnapshot = await _database
          .child('profile/$userId/photo_profile')
          .get();

      if (photoSnapshot.exists && photoSnapshot.value != null) {
        userPhotoUrl.value = photoSnapshot.value.toString();
        print(
          '✅ Photo loaded from profile/$userId/photo_profile: ${userPhotoUrl.value}',
        );
      } else {
        print('⚠️ No photo in profile/$userId/photo_profile, trying fallback');

        // Fallback 1: Try from users path
        if (userSnapshot.exists) {
          final userData = userSnapshot.value as Map<dynamic, dynamic>;
          final photoFromUsers =
              userData['photo_profile'] ?? userData['photoURL'] ?? '';

          if (photoFromUsers.isNotEmpty) {
            userPhotoUrl.value = photoFromUsers;
            print('✅ Photo loaded from users/$userId: $photoFromUsers');
          } else {
            print('⚠️ No photo found in users/$userId');
          }
        }

        // Fallback 2: Try from profile root
        if (userPhotoUrl.value.isEmpty) {
          final profileSnapshot = await _database
              .child('profile/$userId')
              .get();
          if (profileSnapshot.exists) {
            final profileData = profileSnapshot.value as Map<dynamic, dynamic>;
            final photoFromProfile = profileData['photo_profile'] ?? '';

            if (photoFromProfile.isNotEmpty) {
              userPhotoUrl.value = photoFromProfile;
              print(
                '✅ Photo loaded from profile/$userId (root): $photoFromProfile',
              );
            } else {
              print('❌ No photo found anywhere');
            }
          }
        }
      }

      print('📊 Final photo URL: ${userPhotoUrl.value}');
    } catch (e) {
      print('❌ Error fetching user data: $e');
    }
  }

  /// Fetch all posts created by this user
  Future<void> fetchUserPosts() async {
    try {
      isLoading.value = true;

      final userId = _currentUserId;
      if (userId == null) {
        print('No user ID found');
        return;
      }

      print('Fetching posts for user: $userId');

      final snapshot = await _database.child('news').get();

      if (!snapshot.exists) {
        print('No news found in database');
        userPosts.value = [];
        filteredPosts.value = [];
        calculateStats();
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<NewsModel> posts = [];

      data.forEach((key, value) {
        if (value is Map) {
          try {
            final news = NewsModel.fromRealtimeDB(key, value);

            // Only add posts created by this user
            if (news.userId == userId) {
              posts.add(news);
            }
          } catch (e) {
            print('Error parsing news $key: $e');
          }
        }
      });

      // Sort by created_at descending (newest first)
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      userPosts.value = posts;
      filteredPosts.value = posts;

      print('User posts loaded: ${userPosts.length}');

      calculateStats();
      applyFilter();
    } catch (e) {
      print('Error fetching user posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate user statistics
  void calculateStats() {
    totalPosts.value = userPosts.length;
    totalViews.value = userPosts.fold(0, (sum, news) => sum + news.viewCount);
    totalLikes.value = userPosts.fold(0, (sum, news) => sum + news.likeCount);
  }

  /// Get content type of a news item
  String _getContentType(NewsModel news) {
    final hasVideo = news.videoUrl != null && news.videoUrl!.isNotEmpty;
    final hasImage =
        (news.bannerImage != null && news.bannerImage!.isNotEmpty) ||
        (news.images.isNotEmpty && news.images.first.isNotEmpty);

    if (hasVideo) return 'video';
    if (hasImage) return 'photo';
    return 'photo'; // Default to photo
  }

  /// Apply filter to posts
  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredPosts.value = userPosts;
    } else {
      filteredPosts.value = userPosts.where((news) {
        return _getContentType(news) == selectedFilter.value;
      }).toList();
    }

    print(
      'Filtered posts: ${filteredPosts.length} (filter: ${selectedFilter.value})',
    );
  }

  /// Select filter
  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Open post detail
  void openPost(NewsModel news) {
    Get.toNamed('/newsview', arguments: news);
  }

  /// Navigate to news page
  void goToNewsPage() {
    Get.offAllNamed('/home');
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchUserData();
    await fetchUserPosts();
  }

  /// Navigate to edit profile
  void editProfile() {
    Get.toNamed('/editprofile');
  }
}
