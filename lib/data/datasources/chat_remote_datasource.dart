import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';

class ChatRemoteDataSource {
  final Dio _dio;
  CancelToken? _cancelToken;

  ChatRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  String get _apiKey => dotenv.env['NVIDIA_API_KEY'] ?? '';

  Stream<String> sendMessage(String message, List<Map<String, String>> history) async* {
    _cancelToken = CancelToken();

    if (_apiKey.isEmpty) {
      yield '[Error: NVIDIA_API_KEY not found in .env file]';
      return;
    }

    final messages = [
      ...history,
      {'role': 'user', 'content': message},
    ];

    final requestData = {
      'model': ApiConfig.model,
      'messages': messages,
      'temperature': AppConstants.defaultTemperature,
      'top_p': AppConstants.defaultTopP,
      'max_tokens': AppConstants.defaultMaxTokens,
      'stream': true,
    };

    try {
      final response = await _dio.post<ResponseBody>(
        ApiConfig.fullUrl,
        data: jsonEncode(requestData),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          responseType: ResponseType.stream,
        ),
        cancelToken: _cancelToken,
      );

      final stream = response.data?.stream;
      if (stream == null) {
        yield '[Error: No stream response]';
        return;
      }

      String buffer = '';
      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        
        final lines = buffer.split('\n');
        buffer = lines.removeLast();
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              return;
            }
            
            try {
              final json = jsonDecode(data);
              final delta = json['choices']?[0]?['delta']?['content'];
              if (delta != null && delta is String) {
                yield delta;
              }
            } catch (_) {
              // Skip invalid JSON
            }
          }
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        yield '[Stream cancelled]';
      } else {
        yield '[Error: ${e.message}]';
      }
    } catch (e) {
      yield '[Error: $e]';
    }
  }

  void cancelRequest() {
    _cancelToken?.cancel('User cancelled');
  }

  void dispose() {
    _cancelToken?.cancel('Disposed');
  }
}
