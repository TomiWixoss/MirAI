import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_list.dart';
import '../widgets/chat_input.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 28),
            SizedBox(width: 8),
            Text('Mirai'),
          ],
        ),
        actions: [
          BlocBuilder<ChatBloc, ChatBlocState>(
            builder: (context, state) {
              if (state.isStreaming) {
                return IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    context.read<ChatBloc>().add(CancelStreamEvent());
                  },
                  tooltip: 'Stop',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearChatDialog(context);
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatBlocState>(
              builder: (context, state) {
                return ChatList(
                  messages: state.messages,
                  isTyping: state.isStreaming,
                  onRegenerate: (message) {
                    context.read<ChatBloc>().add(RegenerateMessageEvent(message));
                  },
                );
              },
            ),
          ),
          BlocBuilder<ChatBloc, ChatBlocState>(
            builder: (context, state) {
              return ChatInput(
                onSend: (text) {
                  context.read<ChatBloc>().add(SendMessageEvent(text));
                },
                isLoading: state.isStreaming,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(ClearChatEvent());
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
