import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumberkerto_smart_village/app/data/models/news_model.dart';
import 'package:sumberkerto_smart_village/app/data/services/media_compression_service.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class EditnewsController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage2 = GetStorage();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final tagController = TextEditingController();

  // Media files
  final bannerImage = Rxn<File>();
  final images = <File>[].obs;
  final videoFile = Rxn<File>();
  final videoThumbnail = Rxn<File>();

  // Selected tags
  final selectedTags = <String>[].obs;

  // Available tags - Auto-generated
  final availableTags = <String>[
    'Breaking News',
    'Desa',
    'Pembangunan',
    'Kesehatan',
    'Pendidikan',
    'Ekonomi',
    'UMKM',
    'Pertanian',
    'Sosial',
    'Budaya',
    'Lingkungan',
    'Teknologi',
  ].obs;

  // Location suggestions
  final locationSuggestions = <String>[].obs;
  final showLocationSuggestions = false.obs;

  // Common locations in Indonesia
  final commonLocations = <String>[
    'Jakarta',
    'Surabaya',
    'Bandung',
    'Malang',
    'Yogyakarta',
    'Semarang',
    'Medan',
    'Makassar',
    'Bali',
    'Solo',
  ];

  // Loading states
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  final isCompressing = false.obs;

  // Edit mode
  final isEditMode = false.obs;
  NewsModel? editingNews;

  @override
  void onInit() {
    super.onInit();

    // Location search listener
    locationController.addListener(_onLocationChanged);

    // Check if editing existing news
    if (Get.arguments != null && Get.arguments is NewsModel) {
      editingNews = Get.arguments as NewsModel;
      isEditMode.value = true;
      _loadEditData();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    tagController.dispose();
    MediaCompressionService.cleanupTemporary();
    super.onClose();
  }

  /// Get current user data from GetStorage
  String? get _currentUserId {
    return _storage2.read('userId') ?? _auth.currentUser?.uid;
  }

  String get _currentUserName {
    // FIX: Get proper username, fallback to "Anonymous" only if nothing exists
    final userId = _storage2.read('userId');
    final userName =
        _storage2.read('userName') ??
        _storage2.read('name') ??
        _auth.currentUser?.displayName;

    // If we have userId but no name, fetch from database
    if (userId != null && userName == null) {
      _fetchUserNameFromDatabase(userId);
    }

    return userName ?? 'Anonymous';
  }

  /// Fetch username from database if not in storage
  Future<void> _fetchUserNameFromDatabase(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId/name').get();
      if (snapshot.exists) {
        final name = snapshot.value as String;
        _storage2.write('userName', name);
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  /// Load data for editing
  void _loadEditData() {
    if (editingNews == null) return;

    titleController.text = editingNews!.title;
    descriptionController.text = editingNews!.description;
    locationController.text = editingNews!.location ?? '';
    selectedTags.value = List.from(editingNews!.tags);
  }

  /// Location search
  void _onLocationChanged() {
    final query = locationController.text.trim();

    if (query.isEmpty) {
      showLocationSuggestions.value = false;
      locationSuggestions.clear();
      return;
    }

    // Filter locations based on query
    final filtered = commonLocations
        .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.isNotEmpty) {
      locationSuggestions.value = filtered;
      showLocationSuggestions.value = true;
    } else {
      locationSuggestions.clear();
      showLocationSuggestions.value = false;
    }
  }

  /// Select location from suggestions
  void selectLocation(String location) {
    locationController.text = location;
    showLocationSuggestions.value = false;
    locationSuggestions.clear();
  }

  /// Add custom tag
  void addCustomTag() {
    final tag = tagController.text.trim();

    if (tag.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a tag name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (availableTags.contains(tag)) {
      Get.snackbar(
        'Info',
        'Tag already exists',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    availableTags.add(tag);
    selectedTags.add(tag);
    tagController.clear();

    Get.snackbar(
      'Success',
      'Tag "$tag" added',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Pick banner image
  Future<void> pickBannerImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        isCompressing.value = true;
        final File imageFile = File(image.path);
        final compressed = await MediaCompressionService.compressImage(
          imageFile,
        );

        if (compressed != null) {
          bannerImage.value = compressed;
          Get.snackbar(
            'Success',
            'Banner image selected',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
        isCompressing.value = false;
      }
    } catch (e) {
      isCompressing.value = false;
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick images (max 2)
  Future<void> pickImages() async {
    try {
      if (images.length >= 2) {
        Get.snackbar(
          'Limit Reached',
          'Maximum 2 images allowed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isNotEmpty) {
        isCompressing.value = true;

        for (var image in pickedImages) {
          if (images.length >= 2) break;

          final File imageFile = File(image.path);
          final compressed = await MediaCompressionService.compressImage(
            imageFile,
          );

          if (compressed != null) {
            images.add(compressed);
          }
        }

        isCompressing.value = false;
        Get.snackbar(
          'Success',
          '${images.length} image(s) selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isCompressing.value = false;
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Remove image
  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  /// Remove banner
  void removeBanner() {
    bannerImage.value = null;
  }

  /// Pick video
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        isCompressing.value = true;
        Get.snackbar(
          'Compressing',
          'Compressing video to 1MB...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        final File videoFileTemp = File(video.path);

        // Compress video
        final compressed = await MediaCompressionService.compressVideo(
          videoFileTemp,
        );

        if (compressed != null) {
          videoFile.value = compressed;

          // Generate thumbnail
          final thumbnail =
              await MediaCompressionService.generateVideoThumbnail(compressed);
          videoThumbnail.value = thumbnail;

          final size = await compressed.length();
          Get.snackbar(
            'Success',
            'Video compressed to ${(size / 1024 / 1024).toStringAsFixed(2)} MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }

        isCompressing.value = false;
      }
    } catch (e) {
      isCompressing.value = false;
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Remove video
  void removeVideo() {
    videoFile.value = null;
    videoThumbnail.value = null;
  }

  /// Toggle tag selection
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  /// Upload file to Firebase Storage
  Future<String?> _uploadFile(File file, String folder, String fileName) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Validate form
  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedTags.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one tag',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (bannerImage.value == null &&
        videoFile.value == null &&
        images.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one media (banner, image, or video)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Submit news
  Future<void> submitNews() async {
    if (!_validateForm()) return;

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      final userId = _currentUserId;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isUploading.value = false;
        return;
      }

      final userName = _currentUserName;
      final timestamp = DateTime.now();

      // Generate news ID
      final newsRef = isEditMode.value
          ? _database.child('news/${editingNews!.id}')
          : _database.child('news').push();

      final newsId = newsRef.key!;

      String? bannerUrl;
      List<String> imageUrls = [];
      String? videoUrl;
      String? videoThumbnailUrl;

      // Upload banner
      if (bannerImage.value != null) {
        bannerUrl = await _uploadFile(
          bannerImage.value!,
          'news/banners',
          '${newsId}_banner_${timestamp.millisecondsSinceEpoch}.jpg',
        );
      } else if (isEditMode.value) {
        bannerUrl = editingNews!.bannerImage;
      }

      // Upload images
      for (int i = 0; i < images.length; i++) {
        final url = await _uploadFile(
          images[i],
          'news/images',
          '${newsId}_image_${i}_${timestamp.millisecondsSinceEpoch}.jpg',
        );
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // Keep existing images if edit mode and no new images
      if (isEditMode.value && imageUrls.isEmpty) {
        imageUrls = editingNews!.images;
      }

      // Upload video
      if (videoFile.value != null) {
        videoUrl = await _uploadFile(
          videoFile.value!,
          'news/videos',
          '${newsId}_video_${timestamp.millisecondsSinceEpoch}.mp4',
        );

        // Upload thumbnail
        if (videoThumbnail.value != null) {
          videoThumbnailUrl = await _uploadFile(
            videoThumbnail.value!,
            'news/thumbnails',
            '${newsId}_thumbnail_${timestamp.millisecondsSinceEpoch}.jpg',
          );
        }
      } else if (isEditMode.value) {
        videoUrl = editingNews!.videoUrl;
        videoThumbnailUrl = editingNews!.videoThumbnail;
      }

      // Create news data
      final newsData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'created_by': userName,
        'user_id': userId,
        'created_at': timestamp.millisecondsSinceEpoch,
        'tags': selectedTags.toList(),
        'location': locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        'banner_image': bannerUrl,
        'images': imageUrls,
        'video_url': videoUrl,
        'video_thumbnail': videoThumbnailUrl,
        'view_count': isEditMode.value ? editingNews!.viewCount : 0,
        'like_count': isEditMode.value ? editingNews!.likeCount : 0,
      };

      // Save to Realtime Database
      await newsRef.set(newsData);

      // FIX: Show success snackbar and navigate back
      isUploading.value = false;
      uploadProgress.value = 0.0;

      Get.snackbar(
        'Success',
        isEditMode.value
            ? 'News updated successfully!'
            : 'News published successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Wait a bit for snackbar to show then navigate
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate back to news view
      Get.offAllNamed(Routes.NEWS);
    } catch (e) {
      isUploading.value = false;
      uploadProgress.value = 0.0;

      Get.snackbar(
        'Error',
        'Failed to submit news: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
