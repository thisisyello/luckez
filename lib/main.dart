import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:randomlottonumber/shell/main_shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LuckezApp());
}

class LuckezApp extends StatelessWidget {
  const LuckezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainShellPage(),
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
    );
  }
}
