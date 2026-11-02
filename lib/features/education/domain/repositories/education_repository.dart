import '../entities/content_item.dart';

abstract class EducationRepository {
  Future<List<ContentItem>> getFeed();
  
  Future<void> createText({
    required String type,
    String? title,
    String? body,
    String? videoUrl,
  });

  Future<void> createImage({
    required String title,
    required List<int> imageBytes,
    required String fileName,
  });
}
