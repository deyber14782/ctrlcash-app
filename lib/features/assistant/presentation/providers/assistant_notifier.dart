import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/send_message.dart';
import 'assistant_state.dart';

class AssistantNotifier extends Notifier<AssistantState> {
  late final GetHistory _getHistory;
  late final SendMessage _sendMessage;

  @override
  AssistantState build() {
    _getHistory = sl();
    _sendMessage = sl();
    return const AssistantState();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(loadingHistory: true, errorMessage: null);
    try {
      final messages = await _getHistory();
      state = state.copyWith(messages: messages, loadingHistory: false);
    } catch (e) {
      state = state.copyWith(loadingHistory: false, errorMessage: e.toString());
    }
  }

  Future<void> send(String text) async {
    if (state.sending || text.trim().isEmpty) return;

    // Agrega el mensaje del usuario de inmediato (optimista)
    final userMsg = ChatMessage(role: 'user', content: text.trim());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      sending: true,
      errorMessage: null,
    );

    try {
      final reply = await _sendMessage(text.trim());
      final botMsg = ChatMessage(role: 'assistant', content: reply);
      state = state.copyWith(messages: [...state.messages, botMsg], sending: false);
    } catch (e) {
      state = state.copyWith(sending: false, errorMessage: 'No se pudo enviar el mensaje');
    }
  }
}

final assistantNotifierProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);