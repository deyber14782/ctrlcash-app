import '../../domain/entities/content_item.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_datasource.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource remoteDataSource;
  EducationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ContentItem>> getFeed() => remoteDataSource.getFeed();

  @override
  Future<void> createText({
    required String type,
    String? title,
    String? body,
    String? videoUrl,
  }) {
    return remoteDataSource.createTextContent({
      'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (videoUrl != null) 'videoUrl': videoUrl,
    });
  }

  @override
  Future<void> createImage({
    required String title,
    required List<int> imageBytes,
    required String fileName,
  }) {
    return remoteDataSource.createImageContent(
      title: title,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }
}
