import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_datasource.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource remoteDataSource;
  AssistantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChatMessage>> getHistory() => remoteDataSource.getHistory();

  @override
  Future<String> sendMessage(String message) => remoteDataSource.sendMessage(message);
}