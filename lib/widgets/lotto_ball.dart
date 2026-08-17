import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';

class LottoBall extends StatelessWidget {
  const LottoBall({
    super.key,
    required this.number,
  });

  final int number;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ballSize = constraints.maxWidth.clamp(36.0, 56.0);
        final fontSize = (ballSize * 0.4).clamp(16.0, 22.0);

        return Center(
          child: Container(
            width: ballSize,
            height: ballSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(number),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HistoryNumberBall extends StatelessWidget {
  const HistoryNumberBall({
    super.key,
    required this.number,
  });

  final int number;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: getTextColor(number),
      ),
    );
  }
}
