import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: whiteColor,
      child: Center(
        child: Text(
          '커뮤니티 화면 준비 중',
          style: TextStyle(
            color: greyColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
