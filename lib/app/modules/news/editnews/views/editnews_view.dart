import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/editnews_controller.dart';

class EditnewsView extends GetView<EditnewsController> {
  const EditnewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Berita' : 'Berita Baru',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
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
                        color: Colors.black,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: controller.submitNews,
                    child: const Text(
                      'Publish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 16),
                    Text(
                      'Compressing media...',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildLocationField(),
                    const SizedBox(height: 24),
                    _buildTagsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        // Banner Image
        _buildBannerSection(),
        const SizedBox(height: 16),

        // Images
        _buildImagesSection(),
        const SizedBox(height: 16),

        // Video
        _buildVideoSection(),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Obx(
      () => controller.bannerImage.value != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    controller.bannerImage.value!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: controller.removeBanner,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Chip(
                    label: Text(
                      'Banner',
                      style: TextStyle(fontSize: 11, color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            )
          : _buildAddMediaButton(
              'Add Banner Image',
              Icons.image,
              controller.pickBannerImage,
            ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.images.isEmpty
              ? _buildAddMediaButton(
                  'Add Images (Max 2)',
                  Icons.photo_library,
                  controller.pickImages,
                )
              : Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: controller.images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.images[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  padding: const EdgeInsets.all(4),
                                ),
                                onPressed: () => controller.removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (controller.images.length < 2) ...[
                      const SizedBox(height: 12),
                      _buildAddMediaButton(
                        'Add More Images',
                        Icons.add_photo_alternate,
                        controller.pickImages,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Obx(
      () => controller.videoFile.value != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: controller.videoThumbnail.value != null
                      ? Image.file(
                          controller.videoThumbnail.value!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.video_library,
                              size: 48,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: controller.removeVideo,
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
                        return Chip(
                          label: Text(
                            'Video ($sizeMB MB)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            )
          : _buildAddMediaButton(
              'Add Video (Max 1MB)',
              Icons.videocam,
              controller.pickVideo,
            ),
    );
  }

  Widget _buildAddMediaButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
          'Title',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.titleController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter news title...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.descriptionController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Write your description here...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextField(
              controller: controller.locationController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search location...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.locationController.clear();
                    controller.showLocationSuggestions.value = false;
                  },
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            Obx(
              () =>
                  controller.showLocationSuggestions.value &&
                      controller.locationSuggestions.isNotEmpty
                  ? Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.locationSuggestions.length,
                            itemBuilder: (context, index) {
                              final location =
                                  controller.locationSuggestions[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.location_on,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  location,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                onTap: () =>
                                    controller.selectLocation(location),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select relevant tags or add your own',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        // Custom tag input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.tagController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Add custom tag...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => controller.addCustomTag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: controller.addCustomTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableTags.map((tag) {
              final isSelected = controller.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) => controller.toggleTag(tag),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
