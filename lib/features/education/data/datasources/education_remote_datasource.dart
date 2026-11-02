import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/content_item_model.dart';

class EducationRemoteDataSource {
  final ApiClient apiClient;
  EducationRemoteDataSource(this.apiClient);

  Future<List<ContentItemModel>> getFeed() async {
    final res = await apiClient.dio.get('/education');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(ContentItemModel.fromJson).toList();
  }

  // Crea contenido de texto (frase, artículo, video)
  Future<void> createTextContent(Map<String, dynamic> data) async {
    await apiClient.dio.post('/education', data: data);
  }

  // Crea contenido de imagen (sube el archivo a Storage vía backend)
  Future<void> createImageContent({
    required String title,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
    });
    await apiClient.dio.post('/education', data: formData);
  }
}