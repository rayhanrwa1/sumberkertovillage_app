import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/newsview_controller.dart';

class NewsviewView extends GetView<NewsviewController> {
  const NewsviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF2C3E50),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeaderImage()),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        if (controller.news.tags.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              controller.news.tags.first,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2C3E50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          controller.news.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Author info
                        // Di bagian Author info, ganti dengan:
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C3E50).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Obx(() {
                                final name = controller.creatorName.value;
                                return Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name.substring(0, 1).toUpperCase()
                                        : 'A',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.creatorName.value,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      controller.news.createdAt,
                                      locale: 'id',
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stats
                        Row(
                          children: [
                            _buildStat(
                              Icons.visibility_outlined,
                              '${controller.news.viewCount}',
                            ),
                            const SizedBox(width: 20),
                            _buildStat(
                              Icons.favorite_outline,
                              '${controller.news.likeCount}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Description/Content
                        Text(
                          controller.news.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Additional Images
                        if (controller.news.images.isNotEmpty)
                          _buildImageGallery(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    String? imageUrl;

    // Priority: bannerImage > first image > videoThumbnail
    if (controller.news.bannerImage != null &&
        controller.news.bannerImage!.isNotEmpty) {
      imageUrl = controller.news.bannerImage;
    } else if (controller.news.images.isNotEmpty &&
        controller.news.images.first.isNotEmpty) {
      imageUrl = controller.news.images.first;
    } else if (controller.news.videoThumbnail != null &&
        controller.news.videoThumbnail!.isNotEmpty) {
      imageUrl = controller.news.videoThumbnail;
    }

    if (imageUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: const Color(0xFF2C3E50),
      child: Icon(
        Icons.article_outlined,
        size: 64,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeri Foto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.news.images.length,
            itemBuilder: (context, index) {
              final imageUrl = controller.news.images[index];
              if (imageUrl.isEmpty) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
