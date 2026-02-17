import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/data/models/news_model.dart';
import '../controllers/myprofile_controller.dart';

class MyprofileView extends GetView<MyprofileController> {
  const MyprofileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: TColorsConst.white,

        elevation: 0,

        scrolledUnderElevation: 0,

        surfaceTintColor: Colors.transparent,

        shadowColor: Colors.transparent,

        systemOverlayStyle: SystemUiOverlayStyle.dark,

        centerTitle: true,

        title: Text(
          'Profil Saya',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: const Color.fromARGB(255, 96, 197, 255),
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(child: _buildProfileHeader()),

            // Stats
            SliverToBoxAdapter(child: _buildStats()),

            // Filter Tabs
            SliverToBoxAdapter(child: _buildFilterTabs()),

            // Posts Grid
            Obx(() {
              if (controller.isLoading.value && controller.userPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00897B),
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (controller.filteredPosts.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final news = controller.filteredPosts[index];
                    return _buildPostCard(news);
                  }, childCount: controller.filteredPosts.length),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(
      () => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 33, 149, 245),
                    border: Border.all(
                      color: const Color(0xFFf0f0f0),
                      width: 3,
                    ),
                  ),
                  child: controller.userPhotoUrl.value.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: controller.userPhotoUrl.value,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                controller.userName.value.isNotEmpty
                                    ? controller.userName.value[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                // Edit button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.editProfile,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 11, 155, 251),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              controller.userName.value.isNotEmpty
                  ? controller.userName.value
                  : 'Loading...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              controller.userEmail.value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),

            // // Role badge
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFf5f5f5),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(
            //         Icons.verified_user_outlined,
            //         size: 14,
            //         color: Colors.grey[700],
            //       ),
            //       const SizedBox(width: 6),
            //       Text(
            //         controller.userRole.value.toUpperCase(),
            //         style: TextStyle(
            //           fontSize: 11,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.grey[700],
            //           letterSpacing: 0.5,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFfafafa),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.article_outlined,
              value: '${controller.totalPosts.value}',
              label: 'Postingan',
            ),
            Container(width: 1, height: 35, color: const Color(0xFFe0e0e0)),
            _buildStatItem(
              icon: Icons.visibility_outlined,
              value: '${controller.totalViews.value}',
              label: 'Dilihat',
            ),
            // Container(width: 1, height: 35, color: const Color(0xFFe0e0e0)),
            // _buildStatItem(
            //   icon: Icons.favorite_border,
            //   value: '${controller.totalLikes.value}',
            //   label: 'Suka',
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 65, 150, 253), size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final selected = controller.selectedFilter.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua',
              filter: 'all',
              isSelected: selected == 'all',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Video',
              filter: 'video',
              isSelected: selected == 'video',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Foto',
              filter: 'photo',
              isSelected: selected == 'photo',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required String filter,
    required bool isSelected,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectFilter(filter),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 42, 152, 255)
                  : const Color(0xFFfafafa),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF666666),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(NewsModel news) {
    final hasVideo = news.videoUrl != null && news.videoUrl!.isNotEmpty;
    final hasImage =
        (news.bannerImage != null && news.bannerImage!.isNotEmpty) ||
        (news.images.isNotEmpty && news.images.first.isNotEmpty);

    return GestureDetector(
      onTap: () => controller.openPost(news),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFf0f0f0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: hasVideo
                        ? _buildVideoThumbnail(news)
                        : hasImage
                        ? _buildImageThumbnail(news)
                        : _buildNoMediaThumbnail(),
                  ),

                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasVideo
                            ? Colors.black.withOpacity(0.7)
                            : const Color.fromARGB(
                                255,
                                36,
                                161,
                                229,
                              ).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasVideo ? Icons.play_arrow : Icons.image,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasVideo ? 'VIDEO' : 'FOTO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play icon for video
                  if (hasVideo)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.likeCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(NewsModel news) {
    if (news.videoThumbnail != null && news.videoThumbnail!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: news.videoThumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1a1a1a),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF1a1a1a),
          child: const Icon(
            Icons.video_library_outlined,
            color: Colors.white38,
            size: 40,
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFF1a1a1a),
      child: const Icon(
        Icons.video_library_outlined,
        color: Colors.white38,
        size: 40,
      ),
    );
  }

  Widget _buildImageThumbnail(NewsModel news) {
    final imageUrl = news.bannerImage != null && news.bannerImage!.isNotEmpty
        ? news.bannerImage!
        : news.images.first;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFFf5f5f5),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 33, 193, 251),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFf5f5f5),
        child: const Icon(
          Icons.image_outlined,
          color: Color(0xFFcccccc),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildNoMediaThumbnail() {
    return Container(
      color: const Color.fromARGB(255, 17, 155, 229),
      child: Center(
        child: Icon(
          Icons.article_outlined,
          color: Colors.white.withOpacity(0.3),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFf5f5f5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada postingan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mulai berbagi berita dengan komunitas',
            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
