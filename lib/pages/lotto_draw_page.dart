import 'dart:math';

import 'package:flutter/material.dart';
import 'package:randomlottonumber/pages/history_page.dart';
import 'package:randomlottonumber/style.dart';

class LottoDrawPage extends StatefulWidget {
  const LottoDrawPage({super.key});

  @override
  State<LottoDrawPage> createState() => _LottoDrawPageState();
}

class _LottoDrawPageState extends State<LottoDrawPage> {
  List<int> lottoNumbers = [];

  void generateLottoNumbers() {
    Random random = Random();
    Set<int> uniqueNumbers = Set();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          'App Title',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: whiteColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const AboutWinningNumPage(),
              //   ),
              // );
            },
            child: Text(
              '당첨번호 조회',
              style: TextStyle(
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[0]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[0] < 11 ? num0Color : lottoNumbers[0] < 21 ? num10Color : lottoNumbers[0] < 31 ? num20Color  : lottoNumbers[0] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[1]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[1] < 11 ? num0Color : lottoNumbers[1] < 21 ? num10Color : lottoNumbers[1] < 31 ? num20Color  : lottoNumbers[1] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[2]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[2] < 11 ? num0Color : lottoNumbers[2] < 21 ? num10Color : lottoNumbers[2] < 31 ? num20Color  : lottoNumbers[2] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[3]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[3] < 11 ? num0Color : lottoNumbers[3] < 21 ? num10Color : lottoNumbers[3] < 31 ? num20Color  : lottoNumbers[3] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[4]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[4] < 11 ? num0Color : lottoNumbers[4] < 21 ? num10Color : lottoNumbers[4] < 31 ? num20Color  : lottoNumbers[4] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 80,
                          color: blackColor,
                          child: Center(
                            child: Text(
                              '${lottoNumbers[5]}',
                              style: TextStyle(
                                fontSize: 32,
                                // color: open ? whiteColor : blackColor,
                                color: lottoNumbers[5] < 11 ? num0Color : lottoNumbers[5] < 21 ? num10Color : lottoNumbers[5] < 31 ? num20Color  : lottoNumbers[5] < 41 ? num30Color : num40Color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                child: Center(
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
      ),
    );
  }
}
