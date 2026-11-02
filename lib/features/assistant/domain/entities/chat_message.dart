import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String role; // user | assistant
  final String content;

  const ChatMessage({required this.role, required this.content});

  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [role, content];
}