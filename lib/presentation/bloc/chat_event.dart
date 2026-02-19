import 'package:equatable/equatable.dart';
import '../../data/models/message_item.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class RegenerateMessageEvent extends ChatEvent {
  final String originalMessage;

  const RegenerateMessageEvent(this.originalMessage);

  @override
  List<Object?> get props => [originalMessage];
}

class CancelStreamEvent extends ChatEvent {}

class ClearChatEvent extends ChatEvent {}

class LoadChatHistoryEvent extends ChatEvent {
  final List<MessageItem> messages;

  const LoadChatHistoryEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}
