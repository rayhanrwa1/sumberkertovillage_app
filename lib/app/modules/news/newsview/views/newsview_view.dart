import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import '../controllers/newsview_controller.dart';
import 'fullscreen_video_player.dart';
import '../../../../data/models/news_model.dart';
import '../../controllers/news_controller.dart';

class NewsviewView extends GetView<NewsviewController> {
  const NewsviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        controller.news.videoUrl != null &&
        controller.news.videoUrl!.isNotEmpty;
    final hasImages =
        controller.news.images.isNotEmpty ||
        (controller.news.bannerImage != null &&
            controller.news.bannerImage!.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: hasVideo ? 300 : (hasImages ? 250 : 120),
            pinned: true,
            backgroundColor: const Color(0xFF2C3E50),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              // Menu titik 3 untuk edit dan hapus (hanya muncul jika user adalah pemilik berita)
              if (_canEditNews())
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showOptionsDialog(context),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasVideo
                  ? _buildVideoPlayer()
                  : hasImages
                  ? _buildHeaderImage()
                  : _buildNoMediaHeader(),
            ),
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
                        _buildTypeBadge(hasVideo, hasImages),
                        const SizedBox(height: 12),

                        if (controller.news.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.news.tags
                                .take(3)
                                .map((tag) => _buildCategoryTag(tag))
                                .toList(),
                          ),

                        const SizedBox(height: 16),

                        Text(
                          controller.news.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildAuthorInfo(),

                        const SizedBox(height: 16),

                        _buildStatsRow(),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        Text(
                          controller.news.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.7,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 32),

                        if (controller.news.location != null &&
                            controller.news.location!.isNotEmpty)
                          _buildLocationInfo(),

                        if (controller.news.images.length > 1 ||
                            (controller.news.images.length == 1 &&
                                controller.news.bannerImage != null))
                          _buildImageGallery(),

                        const SizedBox(height: 32),
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

  // Cek apakah user bisa edit berita ini
  bool _canEditNews() {
    try {
      final newsController = Get.find<NewsController>();
      return newsController.canDeleteNews(controller.news);
    } catch (e) {
      return false;
    }
  }

  // Dialog options untuk edit dan hapus
  void _showOptionsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Pilih Aksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () {
                Get.back();
                _editNews();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF2C3E50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Edit Berita',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Hapus Berita',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Edit news
  void _editNews() {
    try {
      final newsController = Get.find<NewsController>();
      newsController.editNews(controller.news);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka halaman edit',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Berita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus berita "${controller.news.title}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _deleteNews(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete news
  void _deleteNews(BuildContext context) async {
    try {
      final newsController = Get.find<NewsController>();
      await newsController.deleteNews(controller.news, context);
      // Kembali ke halaman news list setelah delete
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus berita',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Video Player with Fullscreen Button
  Widget _buildVideoPlayer() {
    return Obx(() {
      if (!controller.isVideoInitialized.value) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (controller.news.videoThumbnail != null &&
                controller.news.videoThumbnail!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: controller.news.videoThumbnail!,
                fit: BoxFit.cover,
              )
            else
              Container(color: Colors.grey[900]),
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        );
      }

      return GestureDetector(
        onTap: controller.toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.videoPlayerController!.value.size.width,
                height: controller.videoPlayerController!.value.size.height,
                child: VideoPlayer(controller.videoPlayerController!),
              ),
            ),

            // Gradient overlay when paused
            if (!controller.isVideoPlaying.value)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

            // Play/Pause button
            if (controller.showControls.value ||
                !controller.isVideoPlaying.value)
              Center(
                child: GestureDetector(
                  onTap: controller.togglePlayPause,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isVideoPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),

            // Video controls bar
            if (controller.showControls.value)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        controller.videoPlayerController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time and fullscreen button
                      Row(
                        children: [
                          Text(
                            controller.formatDuration(
                              controller.videoPlayerController!.value.position,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          // Fullscreen button
                          IconButton(
                            icon: const Icon(Icons.fullscreen),
                            color: Colors.white,
                            onPressed: () async {
                              await controller.enterFullscreen();
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.formatDuration(
                              controller.videoPlayerController!.value.duration,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Video badge
            Positioned(
              top: 60,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderImage() {
    String? imageUrl;

    if (controller.news.bannerImage != null &&
        controller.news.bannerImage!.isNotEmpty) {
      imageUrl = controller.news.bannerImage;
    } else if (controller.news.images.isNotEmpty) {
      imageUrl = controller.news.images.first;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildNoMediaHeader();
  }

  Widget _buildNoMediaHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF3498db)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 64,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(bool hasVideo, bool hasImages) {
    IconData icon;
    String label;
    Color color;

    if (hasVideo) {
      icon = Icons.play_arrow;
      label = 'VIDEO';
      color = Colors.red;
    } else if (hasImages) {
      icon = Icons.image;
      label = 'FOTO';
      color = const Color(0xFF2C3E50);
    } else {
      icon = Icons.article;
      label = 'ARTIKEL';
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Obx(() {
              final name = controller.creatorName.value;
              return Center(
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(controller.news.createdAt, locale: 'id'),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.visibility_outlined,
            '${controller.news.viewCount}',
            'Dilihat',
          ),
          // Container(width: 1, height: 30, color: Colors.grey[300]),
          // _buildStatItem(
          //   Icons.favorite_outline,
          //   '${controller.news.likeCount}',
          //   'Suka',
          // ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2C3E50)),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.news.location!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    List<String> galleryImages = [];

    if (controller.news.bannerImage != null &&
        controller.news.bannerImage!.isNotEmpty) {
      galleryImages = controller.news.images
          .where((img) => img.isNotEmpty)
          .toList();
    } else if (controller.news.images.length > 1) {
      galleryImages = controller.news.images
          .skip(1)
          .where((img) => img.isNotEmpty)
          .toList();
    }

    if (galleryImages.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library,
                size: 20,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Galeri Foto (${galleryImages.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              final imageUrl = galleryImages[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 140,
                      height: 140,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C3E50),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 140,
                      height: 140,
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
