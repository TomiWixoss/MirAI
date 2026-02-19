import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../data/models/message_item.dart';

class ChatLocalStorage {
  static const String _fileName = 'chat_history.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<MessageItem>> loadChatHistory() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList
          .map((json) => MessageItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveChatHistory(List<MessageItem> messages) async {
    try {
      final file = await _localFile;
      final jsonList = messages.map((m) => m.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearChatHistory() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }
}
