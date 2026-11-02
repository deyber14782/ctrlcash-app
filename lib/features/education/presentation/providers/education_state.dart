import '../../domain/entities/content_item.dart';

enum EducationStatus { initial, loading, loaded, error }

class EducationState {
  final EducationStatus status;
  final List<ContentItem> items;
  final String? errorMessage;

  const EducationState({
    this.status = EducationStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  EducationState copyWith({
    EducationStatus? status,
    List<ContentItem>? items,
    String? errorMessage,
  }) {
    return EducationState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}