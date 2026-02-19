import 'package:flutter/material.dart';
import '../../data/models/message_item.dart';
import 'chat_bubble.dart';
import 'typing_indicator.dart';

class ChatList extends StatelessWidget {
  final List<MessageItem> messages;
  final bool isTyping;
  final Function(String) onRegenerate;

  const ChatList({
    super.key,
    required this.messages,
    required this.isTyping,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isTyping) {
      return _buildEmptyState();
    }

    String? lastUserMessage;
    for (final msg in messages) {
      if (msg.role == 'user') {
        lastUserMessage = msg.content;
        break;
      }
    }

    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const TypingIndicator();
        }

        final message = messages[index];
        final isUser = message.role == 'user';

        bool showRegenerate = false;
        if (!isUser && !message.isStreaming && lastUserMessage != null) {
          final nextIndex = index + 1;
          if (nextIndex < messages.length) {
            final nextMsg = messages[nextIndex];
            showRegenerate = nextMsg.role == 'user' && !nextMsg.isStreaming;
          }
        }

        return ChatBubble(
          message: message,
          isUser: isUser,
          showRegenerate: showRegenerate,
          onRegenerate: showRegenerate ? () => onRegenerate(lastUserMessage!) : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting with AI',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
