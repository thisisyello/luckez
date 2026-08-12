import 'package:flutter/material.dart';
import 'package:randomlottonumber/data/num_history_lists.dart';
import 'package:randomlottonumber/style.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reversedList = historyNumberLists.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '역대 당첨번호',
          style: TextStyle(color: blackColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          itemCount: reversedList.length,
          itemBuilder: (context, index) {
            final numbers = reversedList[index].sublist(0, 6);
            final bonusNumber = reversedList[index][6];

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '제 ${historyNumberLists.length - index} 회 당첨번호',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...numbers.map(
                        (number) => HistoryNumberBall(
                          number: number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: greyColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      HistoryNumberBall(number: bonusNumber),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
