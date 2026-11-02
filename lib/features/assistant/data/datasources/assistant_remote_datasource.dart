import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat_message.dart';

class AssistantRemoteDataSource {
  final ApiClient apiClient;
  AssistantRemoteDataSource(this.apiClient);

  Future<List<ChatMessage>> getHistory() async {
    final res = await apiClient.dio.get('/assistant/history');
    final messages = (res.data['messages'] as List).cast<Map<String, dynamic>>();
    return messages
        .map((m) => ChatMessage(
              role: m['role'] as String,
              content: m['content'] as String,
            ))
        .toList();
  }

  Future<String> sendMessage(String message) async {
    final res = await apiClient.dio.post('/assistant/chat', data: {'message': message});
    return res.data['reply'] as String;
  }
}