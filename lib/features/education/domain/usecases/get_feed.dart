import '../entities/content_item.dart';
import '../repositories/education_repository.dart';

class GetFeed {
  final EducationRepository repository;
  GetFeed(this.repository);
  Future<List<ContentItem>> call() => repository.getFeed();
}