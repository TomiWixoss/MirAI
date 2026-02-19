import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mirai Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatBloc>().add(ClearChatEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatBlocState>(
        builder: (context, state) {
          return Chat(
            messages: state.messages,
            onSendPressed: (partialText) {
              context.read<ChatBloc>().add(SendMessageEvent(partialText.text));
            },
            user: const types.User(id: 'user'),
            theme: const DefaultChatTheme(
              primaryColor: Color(0xFF6C63FF),
              backgroundColor: Color(0xFFF5F5F5),
            ),
            isAttachmentUploading: state.isStreaming,
          );
        },
      ),
    );
  }
}
