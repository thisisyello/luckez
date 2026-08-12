import 'package:flutter/material.dart';
import 'package:randomlottonumber/pages/lotto_draw_page.dart';

void main() {
  runApp(const LuckezApp());
}

class LuckezApp extends StatelessWidget {
  const LuckezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LottoDrawPage(),
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
    );
  }
}
