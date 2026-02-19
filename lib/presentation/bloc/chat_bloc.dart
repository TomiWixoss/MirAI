import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message_item.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatBlocState> {
  final ChatRepository _repository;
  final _uuid = const Uuid();
  final List<MessageItem> _chatHistory = [];

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatBlocState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<RegenerateMessageEvent>(_onRegenerateMessage);
    on<CancelStreamEvent>(_onCancelStream);
    on<ClearChatEvent>(_onClearChat);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    final userMessageItem = MessageItem(
      id: _uuid.v4(),
      content: event.message,
      role: 'user',
      createdAt: DateTime.now(),
    );

    final currentMessages = List<MessageItem>.from(state.messages);
    currentMessages.add(userMessageItem);

    _chatHistory.add(userMessageItem);

    emit(state.copyWith(
      messages: currentMessages,
      status: ChatStatus.loading,
      isStreaming: true,
    ));

    final assistantMessageId = _uuid.v4();
    String assistantContent = '';

    final streamingMessage = MessageItem(
      id: assistantMessageId,
      content: '',
      role: 'assistant',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    currentMessages.add(streamingMessage);
    emit(state.copyWith(messages: List.from(currentMessages)));

    try {
      await for (final chunk in _repository.sendMessage(event.message, _chatHistory)) {
        assistantContent += chunk;

        final updatedStreamingMessage = streamingMessage.copyWith(
          content: assistantContent,
        );

        final index = currentMessages.indexWhere((m) => m.id == assistantMessageId);
        if (index >= 0) {
          currentMessages[index] = updatedStreamingMessage;
        }

        emit(state.copyWith(
          messages: List.from(currentMessages),
        ));
      }

      final finalAssistantMessage = streamingMessage.copyWith(
        content: assistantContent,
        isStreaming: false,
      );

      final idx = currentMessages.indexWhere((m) => m.id == assistantMessageId);
      if (idx >= 0) {
        currentMessages[idx] = finalAssistantMessage;
      }

      _chatHistory.add(finalAssistantMessage);

      emit(state.copyWith(
        status: ChatStatus.success,
        isStreaming: false,
        messages: List.from(currentMessages),
      ));
    } catch (e) {
      final errorMessage = MessageItem(
        id: _uuid.v4(),
        content: 'Error: ${e.toString()}',
        role: 'assistant',
        createdAt: DateTime.now(),
        isStreaming: false,
      );
      currentMessages.add(errorMessage);

      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
        isStreaming: false,
        messages: List.from(currentMessages),
      ));
    }
  }

  Future<void> _onRegenerateMessage(
    RegenerateMessageEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    if (_chatHistory.isEmpty) return;

    final userMessageIndex = _chatHistory.lastIndexWhere((m) => m.role == 'user');
    if (userMessageIndex == -1) return;

    final userMessage = _chatHistory[userMessageIndex];

    final currentMessages = List<MessageItem>.from(state.messages);
    currentMessages.removeWhere((m) => m.role == 'assistant' && m.isStreaming);

    while (_chatHistory.isNotEmpty && _chatHistory.last.role != 'user') {
      _chatHistory.removeLast();
    }

    emit(state.copyWith(
      messages: currentMessages,
      status: ChatStatus.loading,
      isStreaming: true,
    ));

    final assistantMessageId = _uuid.v4();
    String assistantContent = '';

    final streamingMessage = MessageItem(
      id: assistantMessageId,
      content: '',
      role: 'assistant',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    currentMessages.add(streamingMessage);
    emit(state.copyWith(messages: List.from(currentMessages)));

    try {
      await for (final chunk in _repository.sendMessage(userMessage.content, _chatHistory)) {
        assistantContent += chunk;

        final updatedStreamingMessage = streamingMessage.copyWith(
          content: assistantContent,
        );

        final index = currentMessages.indexWhere((m) => m.id == assistantMessageId);
        if (index >= 0) {
          currentMessages[index] = updatedStreamingMessage;
        }

        emit(state.copyWith(
          messages: List.from(currentMessages),
        ));
      }

      final finalAssistantMessage = streamingMessage.copyWith(
        content: assistantContent,
        isStreaming: false,
      );

      final idx = currentMessages.indexWhere((m) => m.id == assistantMessageId);
      if (idx >= 0) {
        currentMessages[idx] = finalAssistantMessage;
      }

      _chatHistory.add(finalAssistantMessage);

      emit(state.copyWith(
        status: ChatStatus.success,
        isStreaming: false,
        messages: List.from(currentMessages),
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
    _repository.cancelRequest();
    emit(state.copyWith(
      isStreaming: false,
      status: ChatStatus.success,
    ));
  }

  void _onClearChat(ClearChatEvent event, Emitter<ChatBlocState> emit) {
    _chatHistory.clear();
    emit(const ChatBlocState());
  }

  void _onLoadChatHistory(LoadChatHistoryEvent event, Emitter<ChatBlocState> emit) {
    _chatHistory.clear();
    _chatHistory.addAll(event.messages);
    emit(state.copyWith(
      messages: List.from(event.messages),
      status: ChatStatus.success,
    ));
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
