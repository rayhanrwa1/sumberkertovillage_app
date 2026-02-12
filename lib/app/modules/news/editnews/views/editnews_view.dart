import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/editnews_controller.dart';

class EditnewsView extends GetView<EditnewsController> {
  const EditnewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Berita' : 'Buat Berita',
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          Obx(
            () => controller.isUploading.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () => controller.submitNews(context),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isCompressing.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF2C3E50),
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memproses media...',
                      style: TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaSection(context),
                    const SizedBox(height: 24),
                    _buildTitleField(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildCategoryField(),
                    const SizedBox(height: 20),
                    _buildLocationField(),
                    const SizedBox(height: 20),
                    _buildAutoTagsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),

        // Banner Image
        _buildBannerSection(context),
        const SizedBox(height: 12),

        // Images
        _buildImagesSection(context),
        const SizedBox(height: 12),

        // Video
        _buildVideoSection(context),
      ],
    );
  }

  Widget _buildBannerSection(BuildContext context) {
    return Obx(() {
      // Check new upload first
      if (controller.bannerImage.value != null) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                controller.bannerImage.value!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeBanner,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Banner Baru',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Check existing banner
      if (controller.existingBannerUrl.value != null) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: controller.existingBannerUrl.value!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error_outline),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeExistingBanner,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Banner',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // No banner - show add button
      return _buildAddMediaButton(
        'Tambah Banner',
        Icons.image_outlined,
        () => controller.pickBannerImage(context),
      );
    });
  }

  Widget _buildImagesSection(BuildContext context) {
    return Obx(() {
      final hasExistingImages = controller.existingImageUrls.isNotEmpty;
      final hasNewImages = controller.images.isNotEmpty;
      final totalImages =
          controller.existingImageUrls.length + controller.images.length;

      if (!hasExistingImages && !hasNewImages) {
        return _buildAddMediaButton(
          'Tambah Gambar (Maks 2)',
          Icons.photo_library_outlined,
          () => controller.pickImages(context),
        );
      }

      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: totalImages,
            itemBuilder: (context, index) {
              // Show existing images first
              if (index < controller.existingImageUrls.length) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: controller.existingImageUrls[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2C3E50),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Show new images
                final newImageIndex =
                    index - controller.existingImageUrls.length;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.images[newImageIndex],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(newImageIndex),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    // Label for new images
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Baru',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          if (totalImages < 2) ...[
            const SizedBox(height: 12),
            _buildAddMediaButton(
              'Tambah Gambar Lagi',
              Icons.add_photo_alternate_outlined,
              () => controller.pickImages(context),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildVideoSection(BuildContext context) {
    return Obx(() {
      // Check new video upload first
      if (controller.videoFile.value != null) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: controller.videoThumbnail.value != null
                  ? Image.file(
                      controller.videoThumbnail.value!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.video_library_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: FutureBuilder<int>(
                future: controller.videoFile.value!.length(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final sizeMB = (snapshot.data! / 1024 / 1024)
                        .toStringAsFixed(2);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Video Baru ($sizeMB MB)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        );
      }

      // Check existing video
      if (controller.existingVideoUrl.value != null) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: controller.existingVideoThumbnailUrl.value != null
                  ? CachedNetworkImage(
                      imageUrl: controller.existingVideoThumbnailUrl.value!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.video_library_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.video_library_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeExistingVideo,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // No video - show add button
      return _buildAddMediaButton(
        'Tambah Video (Maks 1MB)',
        Icons.videocam_outlined,
        () => controller.pickVideo(context),
      );
    });
  }

  Widget _buildAddMediaButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.grey[500]),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller.titleController,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Masukkan judul berita...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 2,
            onChanged: (_) => controller.generateAutoTags(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller.descriptionController,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Tulis deskripsi...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 6,
            onChanged: (_) => controller.generateAutoTags(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return // Di view Anda, tambahkan Stack untuk menampilkan suggestions
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            // TextField Kategori
            TextField(
              controller: controller.categoryController,
              decoration: InputDecoration(
                hintText: 'Masukkan kategori...',
                prefixIcon: Icon(Icons.category_outlined),
                suffixIcon: controller.categoryController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.categoryController.clear();
                          controller.showCategorySuggestions.value = false;
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Trigger akan otomatis dari listener di controller
              },
            ),

            // Suggestions dropdown
            Obx(() {
              if (!controller.showCategorySuggestions.value ||
                  controller.categorySuggestions.isEmpty) {
                return SizedBox.shrink();
              }

              return Positioned(
                top: 60, // Sesuaikan dengan tinggi TextField
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.categorySuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion =
                            controller.categorySuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.tag, size: 20),
                          title: Text(suggestion),
                          onTap: () {
                            controller.selectCategorySuggestion(suggestion);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ),

        // Show available categories if any
        Obx(() {
          if (controller.availableCategories.isEmpty) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Kategori Populer',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableCategories.map((category) {
                  final isSelected =
                      controller.selectedCategory.value == category;
                  return GestureDetector(
                    onTap: () => controller.selectCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2C3E50)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2C3E50)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            // TextField Lokasi
            TextField(
              controller: controller.locationController,
              decoration: InputDecoration(
                hintText: 'Pilih lokasi...',
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: controller.locationController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.locationController.clear();
                          controller.showLocationSuggestions.value = false;
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Suggestions dropdown
            Obx(() {
              if (!controller.showLocationSuggestions.value ||
                  controller.locationSuggestions.isEmpty) {
                return SizedBox.shrink();
              }

              return Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.locationSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion =
                            controller.locationSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.place, size: 20),
                          title: Text(suggestion),
                          onTap: () {
                            controller.selectLocation(suggestion);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '💡 Tip: Ketik nama kota untuk melihat saran lokasi',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoTagsSection() {
    return Obx(() {
      if (controller.autoGeneratedTags.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tag Otomatis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Generated',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.autoGeneratedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => controller.removeTag(tag),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Tag dibuat otomatis dari judul dan deskripsi',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    });
  }
}
