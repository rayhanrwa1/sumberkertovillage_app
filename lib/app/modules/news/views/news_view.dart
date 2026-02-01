import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import '../../../data/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTagFilters(),
            Expanded(child: _buildNewsList()),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isCreateDisabled.value
              ? null
              : controller.createNews,
          backgroundColor: controller.isCreateDisabled.value
              ? Colors.grey
              : Colors.black,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Buat Berita',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Text(
            'Cari Artikel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: controller.updateSearch,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Search for an article...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: Icon(Icons.tune, color: Colors.grey[600]),
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

  Widget _buildTagFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.availableTags.length,
          itemBuilder: (context, index) {
            final tag = controller.availableTags[index];
            final isSelected = controller.selectedTags.contains(tag);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.newsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black),
        );
      }

      if (controller.filteredNews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No articles found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshNews,
        color: Colors.black,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredNews.length,
          itemBuilder: (context, index) {
            final news = controller.filteredNews[index];

            // Load more when reaching end
            if (index == controller.filteredNews.length - 1) {
              controller.fetchNews();
            }

            return _buildNewsCard(news);
          },
        ),
      );
    });
  }

  Widget _buildNewsCard(NewsModel news) {
    return GestureDetector(
      onTap: () => controller.openNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media section
            if (news.videoUrl != null)
              _buildVideoThumbnail(news)
            else if (news.bannerImage != null)
              _buildBannerImage(news.bannerImage!)
            else if (news.images.isNotEmpty)
              _buildBannerImage(news.images.first),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: news.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    news.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Author and stats
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.createdBy,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              timeago.format(news.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.favorite_outline,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.likeCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildBannerImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(NewsModel news) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: news.videoThumbnail != null
              ? CachedNetworkImage(
                  imageUrl: news.videoThumbnail!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(height: 200, color: Colors.grey[200]),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.video_library,
                    size: 48,
                    color: Colors.black,
                  ),
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
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
      ],
    );
  }
}
