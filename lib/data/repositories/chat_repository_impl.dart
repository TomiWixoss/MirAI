import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/message_item.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource();

  @override
  Stream<String> sendMessage(String message, List<MessageItem> history) {
    final historyJson = history
        .where((m) => m.role != 'system')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
    
    return _remoteDataSource.sendMessage(message, historyJson);
  }

  @override
  void cancelRequest() {
    _remoteDataSource.cancelRequest();
  }

  @override
  void dispose() {
    _remoteDataSource.dispose();
  }
}
