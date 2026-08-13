import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '구매',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: const Center(
        child: Text(
          '구매 연결 준비 중',
          style: TextStyle(
            color: greyColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
