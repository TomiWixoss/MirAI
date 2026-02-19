import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'presentation/pages/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ChatRepository>(
      create: (context) => ChatRepositoryImpl(),
      child: BlocProvider(
        create: (context) => ChatBloc(
          repository: context.read<ChatRepository>(),
        ),
        child: MaterialApp(
          title: 'Mirai Chat',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
            useMaterial3: true,
          ),
          home: const ChatPage(),
        ),
      ),
    );
  }
}
