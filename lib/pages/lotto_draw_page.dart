import 'dart:math';

import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/lotto_ball.dart';

class LottoDrawPage extends StatefulWidget {
  const LottoDrawPage({
    super.key,
    required this.savedNumbersCount,
    required this.onSaveNumbers,
  });

  final int savedNumbersCount;
  final ValueChanged<List<int>> onSaveNumbers;

  @override
  State<LottoDrawPage> createState() => _LottoDrawPageState();
}

class _LottoDrawPageState extends State<LottoDrawPage> {
  List<int> lottoNumbers = [];

  void generateLottoNumbers() {
    Random random = Random();
    Set<int> uniqueNumbers = <int>{};

    while (uniqueNumbers.length < 6) {
      int newNumber = random.nextInt(45) + 1;
      uniqueNumbers.add(newNumber);
    }

    setState(() {
      lottoNumbers = uniqueNumbers.toList();
      lottoNumbers.sort();
    });
  }

  void saveCurrentLottoNumbers() {
    widget.onSaveNumbers(lottoNumbers);
  }

  @override
  void initState() {
    super.initState();
    generateLottoNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: whiteColor,
      child: PageContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Row(
                    children: lottoNumbers
                        .map(
                          (number) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: LottoBall(number: number),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: '다시 뽑기',
                        onPressed: generateLottoNumbers,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: '저장하기',
                        onPressed: saveCurrentLottoNumbers,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '저장한 번호 ${widget.savedNumbersCount}개',
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
