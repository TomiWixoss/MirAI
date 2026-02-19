import '../../data/models/message_item.dart';

abstract class ChatRepository {
  Stream<String> sendMessage(String message, List<MessageItem> history);
  void cancelRequest();
  void dispose();
}
