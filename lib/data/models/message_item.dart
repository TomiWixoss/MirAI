import 'package:equatable/equatable.dart';

class MessageItem extends Equatable {
  final String id;
  final String content;
  final String role;
  final DateTime createdAt;
  final bool isStreaming;

  const MessageItem({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.isStreaming = false,
  });

  MessageItem copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return MessageItem(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, content, role, createdAt, isStreaming];
}
