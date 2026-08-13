import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class MyNumbersPage extends StatelessWidget {
  const MyNumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '내 번호',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: const Center(
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
