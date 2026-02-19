class MessageModel {
  final String id;
  final String content;
  final String role;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory MessageModel.fromStreamingChunk(String chunk) {
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: chunk,
      role: 'assistant',
    );
  }
}
