import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: whiteColor,
      child: Center(
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
