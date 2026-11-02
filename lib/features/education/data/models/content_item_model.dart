import '../../domain/entities/content_item.dart';

class ContentItemModel extends ContentItem {
  const ContentItemModel({
    required super.id,
    required super.type,
    super.title,
    super.body,
    super.imageUrl,
    super.videoUrl,
    super.youtubeId,
    required super.createdAt,
  });

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      youtubeId: json['youtubeId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}