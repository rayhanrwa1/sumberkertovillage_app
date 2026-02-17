import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/news/widgets/author_avatar.dart';
import '../controllers/news_controller.dart';
import '../../../data/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildContentTypeTabs(),
            Expanded(child: _buildNewsList(context)),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.isCreateDisabled.value
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: controller.createNews,
                backgroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF2C3E50),
                  size: 28,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Berita',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Builder(
            builder: (context) {
              final userId = controller.currentUserId;
              if (userId == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () => Get.toNamed('/myprofile'),
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AuthorAvatar(
                      userId: userId,
                      fallbackName: 'User',
                      size: 40,
                      showBorder: true,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.updateSearch,
          style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Cari berita...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeTabs() {
    return Obx(() {
      final selectedType = controller.selectedContentType.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: _buildContentTypeTab(
                label: 'Video',
                icon: Icons.play_circle_outline,
                type: 'video',
                isSelected: selectedType == 'video',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContentTypeTab(
                label: 'Post',
                icon: Icons.article_outlined,
                type: 'post',
                isSelected:
                    selectedType == 'post' ||
                    selectedType == 'all' ||
                    selectedType == 'photo' ||
                    selectedType == 'text',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContentTypeTab({
    required String label,
    required IconData icon,
    required String type,
    required bool isSelected,
  }) {
    Color getColor() {
      if (!isSelected) return Colors.grey[600]!;
      return type == 'video'
          ? const Color.fromARGB(255, 39, 154, 255)
          : const Color(0xFF2C3E50);
    }

    Color getBgColor() {
      if (!isSelected) return Colors.white;
      return type == 'video'
          ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1)
          : const Color(0xFF2C3E50).withOpacity(0.1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectContentType(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? getBgColor() : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? getColor() : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: getColor().withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: getColor(), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: getColor(),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.newsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C3E50),
            strokeWidth: 2,
          ),
        );
      }

      if (controller.filteredNews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Belum ada berita',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshNews(context: context),
        color: const Color(0xFF2C3E50),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredNews.length,
          itemBuilder: (context, index) {
            final news = controller.filteredNews[index];

            if (index == controller.filteredNews.length - 1) {
              controller.fetchNews(context: context);
            }

            return _buildNewsCard(news, context);
          },
        ),
      );
    });
  }

  Widget _buildNewsCard(NewsModel news, BuildContext context) {
    final hasVideo = news.videoUrl != null && news.videoUrl!.isNotEmpty;
    final hasImage =
        (news.bannerImage != null && news.bannerImage!.isNotEmpty) ||
        (news.images.isNotEmpty && news.images.first.isNotEmpty);

    return GestureDetector(
      onTap: () => controller.openNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasVideo)
              _buildVideoCard(news)
            else if (hasImage)
              _buildImageCard(news)
            else
              _buildNoMediaCard(news),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(NewsModel news) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 450,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (news.videoThumbnail != null && news.videoThumbnail!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: news.videoThumbnail!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey[900],
                child: const Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 60,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              news.createdBy.isNotEmpty
                                  ? news.createdBy.substring(0, 1).toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.createdBy.isNotEmpty
                                    ? news.createdBy
                                    : 'Anonymous',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                timeago.format(news.createdAt, locale: 'id'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // _buildVideoActionButton(
                  //   Icons.favorite_outline,
                  //   '${news.likeCount}',
                  // ),
                  const SizedBox(height: 20),
                  _buildVideoActionButton(
                    Icons.visibility_outlined,
                    '${news.viewCount}',
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 72,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(NewsModel news) {
    final imageUrl = news.bannerImage != null && news.bannerImage!.isNotEmpty
        ? news.bannerImage!
        : news.images.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2C3E50),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Icon(Icons.error_outline, color: Colors.grey[400]),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.image, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'POST',
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
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                news.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildAuthorAndStats(news),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoMediaCard(NewsModel news) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.article, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'POST',
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
          const SizedBox(height: 12),
          Text(
            news.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            news.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _buildAuthorAndStats(news),
        ],
      ),
    );
  }

  Widget _buildAuthorAndStats(NewsModel news) {
    return Row(
      children: [
        AuthorAvatar(
          userId: news.userId,
          fallbackName: news.createdBy,
          size: 32,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news.createdBy.isNotEmpty ? news.createdBy : 'Anonymous',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                timeago.format(news.createdAt, locale: 'id'),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          '${news.viewCount}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.favorite_outline, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          '${news.likeCount}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
      ],
    );
  }
}
