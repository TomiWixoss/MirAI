import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

enum ChatStatus { initial, loading, success, error }

class ChatBlocState extends Equatable {
  final List<types.Message> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool isStreaming;

  const ChatBlocState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.isStreaming = false,
  });

  ChatBlocState copyWith({
    List<types.Message>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool? isStreaming,
  }) {
    return ChatBlocState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage, isStreaming];
}
