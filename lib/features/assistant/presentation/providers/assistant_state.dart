import '../../domain/entities/chat_message.dart';

class AssistantState {
  final List<ChatMessage> messages;
  final bool loadingHistory;
  final bool sending;
  final String? errorMessage;

  const AssistantState({
    this.messages = const [],
    this.loadingHistory = false,
    this.sending = false,
    this.errorMessage,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? loadingHistory,
    bool? sending,
    String? errorMessage,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      loadingHistory: loadingHistory ?? this.loadingHistory,
      sending: sending ?? this.sending,
      errorMessage: errorMessage,
    );
  }
}