import 'package:equatable/equatable.dart';
import '../../data/models/message_item.dart';

enum ChatStatus { initial, loading, success, error }

class ChatBlocState extends Equatable {
  final List<MessageItem> messages;
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
    List<MessageItem>? messages,
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
