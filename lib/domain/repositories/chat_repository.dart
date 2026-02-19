import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<String> sendMessage(String message, List<ChatMessage> history);
  void dispose();
}
