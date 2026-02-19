import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/chat_theme.dart';
import '../../data/models/message_item.dart';

class ChatBubble extends StatelessWidget {
  final MessageItem message;
  final bool isUser;
  final VoidCallback? onRegenerate;
  final bool showRegenerate;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.onRegenerate,
    this.showRegenerate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isUser ? ChatTheme.userMessageColor : ChatTheme.aiMessageColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isUser ? 24 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  message.content,
                  style: TextStyle(
                    color: isUser ? ChatTheme.userTextColor : ChatTheme.aiTextColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                if (message.isStreaming)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                  _ActionButton(
                    icon: Icons.copy,
                    onTap: () => _copyToClipboard(context),
                    tooltip: 'Copy',
                  ),
                  if (showRegenerate)
                    _ActionButton(
                      icon: Icons.refresh,
                      onTap: onRegenerate,
                      tooltip: 'Regenerate',
                    ),
                ],
                const SizedBox(width: 8),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
