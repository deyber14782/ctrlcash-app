import '../repositories/assistant_repository.dart';

class SendMessage {
  final AssistantRepository repository;
  SendMessage(this.repository);
  Future<String> call(String message) => repository.sendMessage(message);
}