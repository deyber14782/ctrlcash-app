import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class GetHistory {
  final AssistantRepository repository;
  GetHistory(this.repository);
  Future<List<ChatMessage>> call() => repository.getHistory();
}