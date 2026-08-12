import 'package:flutter/material.dart';
import 'package:randomlottonumber/data/num_history_lists.dart';
import 'package:randomlottonumber/pages/lotto_draw_page.dart';
import 'package:randomlottonumber/style.dart';

void main() {
  runApp(LuckezApp());
}

bool darkMode = false;

class LuckezApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LottoDrawPage(),
      theme: ThemeData(
        fontFamily: 'Pretendard'
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> _lottoNumbers = [];

  @override
  void initState() {
    super.initState();
    _generateLottoNumbers();
    print(darkMode);
  }

  void _generateLottoNumbers() {
    setState(() {
      _lottoNumbers = (List.generate(45, (index) => index + 1)..shuffle()).take(6).toList()..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.history, color: darkMode ? whiteColor : blackColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.wb_sunny, color: darkMode ? whiteColor : blackColor),
              onPressed: () {
                setState(() {
                  if (darkMode == true) {
                    darkMode = false;
                  } else {
                    darkMode = true;
                  }
                });
                print(darkMode);
              },
            ),
          ),
        ],
      ),
      backgroundColor: darkMode ? blackColor : whiteColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _lottoNumbers.map((num) => LottoBall(number: num, textColor: getTextColor(num))).toList(),
          ),
          const SizedBox(height: 40),
          InkWell(
            onTap: _generateLottoNumbers,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Draw',
                style: TextStyle(
                  fontSize: 18,
                  color: whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LottoBall extends StatelessWidget {
  final int number;
  final Color textColor;
  LottoBall({required this.number, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: whiteColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}


class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reversedList = historyNumberLists.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('역대 당첨번호', style: TextStyle(color: darkMode ? whiteColor : blackColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkMode ? whiteColor : blackColor),
      ),
      backgroundColor: darkMode ? blackColor : whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          itemCount: reversedList.length,
          itemBuilder: (context, index) {
            List<int> numbers = reversedList[index].sublist(0, 6);
            int bonusNumber = reversedList[index][6];
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkMode ? blackColor : whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '제 ${historyNumberLists.length - index} 회 당첨번호',
                    style: TextStyle(fontWeight: FontWeight.bold, color: darkMode ? whiteColor : blackColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...numbers.map((num) => HistoryNumerBall(number: num, textColor: getTextColor(num))),
                      const SizedBox(width: 8),
                      Text(
                        '+',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: greyColor),
                      ),
                      const SizedBox(width: 8),
                      HistoryNumerBall(number: bonusNumber, textColor: getTextColor(bonusNumber)),
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

class HistoryNumerBall extends StatelessWidget {
  final int number;
  final Color textColor;
  HistoryNumerBall({required this.number, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}
