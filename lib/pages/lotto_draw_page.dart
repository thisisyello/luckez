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

  bool open = false;

  @override
  void initState() {
    super.initState();
    generateLottoNumbers();
    // print(allHistoryNumbers);
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
          InkWell(
            onTap: () {
              setState(() {
                open = true;
              });
              generateLottoNumbers();
              // print(lottoNumbers);//////
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: mainColor,
              ),
              child: const Center(
                child: Text(
                  '번호 추출하기',
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
