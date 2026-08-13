import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class MyNumbersPage extends StatelessWidget {
  const MyNumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: whiteColor,
      child: Center(
        child: Text(
          '저장한 번호 화면 준비 중',
          style: TextStyle(
            color: greyColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
