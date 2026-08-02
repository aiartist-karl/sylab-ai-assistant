import 'package:flutter/material.dart';
import 'common/storage_util.dart';
import 'pages/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtil.initHive();
  runApp(const SylabApp());
}

class SylabApp extends StatelessWidget {
  const SylabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sylab AI助手',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}
