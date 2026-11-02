import '../entities/chat_message.dart';

abstract class AssistantRepository {
  Future<List<ChatMessage>> getHistory();
  Future<String> sendMessage(String message);
}