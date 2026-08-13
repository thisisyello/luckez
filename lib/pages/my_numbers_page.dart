import 'package:flutter/material.dart';
import 'package:randomlottonumber/models/saved_lotto_number.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class MyNumbersPage extends StatelessWidget {
  const MyNumbersPage({
    super.key,
    required this.savedNumbers,
  });

  final List<SavedLottoNumber> savedNumbers;

  @override
  Widget build(BuildContext context) {
    if (savedNumbers.isEmpty) {
      return const ColoredBox(
        color: whiteColor,
        child: Center(
          child: Text(
            '아직 저장한 번호가 없습니다',
            style: TextStyle(
              color: greyColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final reversedNumbers = savedNumbers.reversed.toList();

    return ColoredBox(
      color: whiteColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: reversedNumbers.length,
        itemBuilder: (context, index) {
          final savedNumber = reversedNumbers[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '저장 번호 ${savedNumbers.length - index}',
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: savedNumber.numbers
                      .map(
                        (number) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: LottoBall(number: number),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  _formatCreatedAt(savedNumber.createdAt),
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCreatedAt(DateTime createdAt) {
    final year = createdAt.year.toString();
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$year.$month.$day $hour:$minute 저장';
  }
}
