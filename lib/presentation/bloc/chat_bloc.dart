import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatBlocState> {
  final ChatRepository _repository;
  final _uuid = const Uuid();
  final types.User _user = types.User(
    id: 'user',
    firstName: 'You',
  );
  final types.User _assistant = types.User(
    id: 'assistant',
    firstName: 'Mirai',
  );

  List<ChatMessage> _chatHistory = [];

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatBlocState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<CancelStreamEvent>(_onCancelStream);
    on<ClearChatEvent>(_onClearChat);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    final userMessage = types.TextMessage(
      id: _uuid.v4(),
      author: _user,
      text: event.message,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final currentMessages = List<types.Message>.from(state.messages);
    currentMessages.insert(0, userMessage);

    _chatHistory.add(ChatMessage(
      id: userMessage.id,
      content: event.message,
      role: 'user',
      createdAt: DateTime.now(),
    ));

    emit(state.copyWith(
      messages: currentMessages,
      status: ChatStatus.loading,
      isStreaming: true,
    ));

    final assistantMessageId = _uuid.v4();
    String assistantContent = '';

    try {
      await for (final chunk in _repository.sendMessage(event.message, _chatHistory)) {
        assistantContent += chunk;

        final existingIndex = currentMessages.indexWhere(
          (m) => m.id == assistantMessageId,
        );

        if (existingIndex >= 0) {
          currentMessages.removeAt(existingIndex);
        }

        final assistantMessage = types.TextMessage(
          id: assistantMessageId,
          author: _assistant,
          text: assistantContent,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        currentMessages.insert(0, assistantMessage);

        emit(state.copyWith(
          messages: List.from(currentMessages),
        ));
      }

      _chatHistory.add(ChatMessage(
        id: assistantMessageId,
        content: assistantContent,
        role: 'assistant',
        createdAt: DateTime.now(),
      ));

      emit(state.copyWith(
        status: ChatStatus.success,
        isStreaming: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
        isStreaming: false,
      ));
    }
  }

  void _onCancelStream(CancelStreamEvent event, Emitter<ChatBlocState> emit) {
    emit(state.copyWith(
      isStreaming: false,
      status: ChatStatus.success,
    ));
  }

  void _onClearChat(ClearChatEvent event, Emitter<ChatBlocState> emit) {
    _chatHistory = [];
    emit(const ChatBlocState());
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
