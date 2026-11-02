import '../repositories/education_repository.dart';

class CreateImageContent {
  final EducationRepository repository;
  CreateImageContent(this.repository);

  Future<void> call({
    required String title,
    required List<int> imageBytes,
    required String fileName,
  }) {
    return repository.createImage(
      title: title, imageBytes: imageBytes, fileName: fileName);
  }
}