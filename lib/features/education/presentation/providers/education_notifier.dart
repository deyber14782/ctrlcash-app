import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_feed.dart';
import 'education_state.dart';
import '../../domain/usecases/create_text_content.dart';
import '../../domain/usecases/create_image_content.dart';

class EducationNotifier extends Notifier<EducationState> {
  late final GetFeed _getFeed;
  late final CreateTextContent _createText;
  late final CreateImageContent _createImage;

  @override
  EducationState build() {
    _getFeed = sl();
    _createText = sl();
    _createImage = sl();
    return const EducationState();
  }

  Future<void> load() async {
    state = state.copyWith(status: EducationStatus.loading, errorMessage: null);
    try {
      final items = await _getFeed();
      state = state.copyWith(status: EducationStatus.loaded, items: items);
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> publishText({
    required String type,
    String? title,
    String? body,
    String? videoUrl,
  }) async {
    try {
      await _createText(
        type: type,
        title: title,
        body: body,
        videoUrl: videoUrl,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> publishImage({
    required String title,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      await _createImage(
        title: title,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final educationNotifierProvider =
    NotifierProvider<EducationNotifier, EducationState>(EducationNotifier.new);
