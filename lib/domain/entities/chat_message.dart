import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final String role;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, content, role, createdAt];
}
