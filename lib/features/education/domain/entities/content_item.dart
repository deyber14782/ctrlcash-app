import 'package:equatable/equatable.dart';

class ContentItem extends Equatable {
  final String id;
  final String type; // frase | articulo | imagen | video
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? videoUrl;
  final String? youtubeId;
  final DateTime createdAt;

  const ContentItem({
    required this.id,
    required this.type,
    this.title,
    this.body,
    this.imageUrl,
    this.videoUrl,
    this.youtubeId,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, type, title, body, imageUrl, videoUrl, youtubeId, createdAt];
}