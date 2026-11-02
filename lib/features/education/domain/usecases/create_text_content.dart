import '../repositories/education_repository.dart';

class CreateTextContent {
  final EducationRepository repository;
  CreateTextContent(this.repository);

  Future<void> call({
    required String type,
    String? title,
    String? body,
    String? videoUrl,
  }) {
    return repository.createText(
      type: type, title: title, body: body, videoUrl: videoUrl);
  }
}