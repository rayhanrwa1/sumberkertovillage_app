class NewsModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String userId;
  final DateTime createdAt;
  final List<String> tags;
  final String? location;
  final String? bannerImage;
  final List<String> images;
  final String? videoUrl;
  final String? videoThumbnail;
  final int viewCount;
  final int likeCount;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.userId,
    required this.createdAt,
    required this.tags,
    this.location,
    this.bannerImage,
    this.images = const [],
    this.videoUrl,
    this.videoThumbnail,
    this.viewCount = 0,
    this.likeCount = 0,
  });

  // From Realtime Database
  factory NewsModel.fromRealtimeDB(String key, Map<dynamic, dynamic> data) {
    return NewsModel(
      id: key,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdBy: data['created_by']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      tags: data['tags'] != null 
          ? List<String>.from((data['tags'] as List).map((e) => e.toString()))
          : [],
      location: data['location']?.toString(),
      bannerImage: data['banner_image']?.toString(),
      images: data['images'] != null
          ? List<String>.from((data['images'] as List).map((e) => e.toString()))
          : [],
      videoUrl: data['video_url']?.toString(),
      videoThumbnail: data['video_thumbnail']?.toString(),
      viewCount: data['view_count'] as int? ?? 0,
      likeCount: data['like_count'] as int? ?? 0,
    );
  }

  // To Realtime Database
  Map<String, dynamic> toRealtimeDB() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'user_id': userId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'tags': tags,
      'location': location,
      'banner_image': bannerImage,
      'images': images,
      'video_url': videoUrl,
      'video_thumbnail': videoThumbnail,
      'view_count': viewCount,
      'like_count': likeCount,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? userId,
    DateTime? createdAt,
    List<String>? tags,
    String? location,
    String? bannerImage,
    List<String>? images,
    String? videoUrl,
    String? videoThumbnail,
    int? viewCount,
    int? likeCount,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      bannerImage: bannerImage ?? this.bannerImage,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}