import 'package:flutter/material.dart';
import 'package:randomlottonumber/shell/main_shell_page.dart';

void main() {
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
