import 'dart:math';

import 'package:flutter/material.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class LottoDrawPage extends StatefulWidget {
  const LottoDrawPage({super.key});

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

  void showSaveComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('번호 저장 기능 준비 중'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    generateLottoNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: whiteColor,
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  child: OutlinedButton(
                    onPressed: generateLottoNumbers,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: mainColor,
                      side: const BorderSide(color: mainColor),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('다시 추첨'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: showSaveComingSoonMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('저장하기'),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              '저장한 번호 0개',
              style: TextStyle(
                color: greyColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
