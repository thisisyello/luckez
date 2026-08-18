import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: whiteColor,
      child: PageContentWidth(
        child: Center(
          child: Text(
            '구매 연결 준비 중',
            style: TextStyle(
              color: greyColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
