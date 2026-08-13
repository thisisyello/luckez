import 'package:flutter/material.dart';
import 'package:randomlottonumber/models/saved_lotto_number.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class MyNumbersPage extends StatefulWidget {
  const MyNumbersPage({
    super.key,
    required this.savedNumbers,
    required this.activeRound,
  });

  final List<SavedLottoNumber> savedNumbers;
  final int activeRound;

  @override
  State<MyNumbersPage> createState() => _MyNumbersPageState();
}

class _MyNumbersPageState extends State<MyNumbersPage> {
  late int selectedRound;

  @override
  void initState() {
    super.initState();
    selectedRound = widget.activeRound;
  }

  @override
  void didUpdateWidget(MyNumbersPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeRound != widget.activeRound) {
      selectedRound = widget.activeRound;
    }
  }

  int get minRound {
    final savedRounds = widget.savedNumbers
        .map((savedNumber) => savedNumber.round)
        .whereType<int>()
        .toList();

    if (savedRounds.isEmpty) {
      return widget.activeRound;
    }

    return savedRounds.reduce((a, b) => a < b ? a : b);
  }

  bool get canGoPrevious => selectedRound > minRound;
  bool get canGoNext => selectedRound < widget.activeRound;

  @override
  Widget build(BuildContext context) {
    final selectedRoundNumbers = widget.savedNumbers
        .where((savedNumber) => savedNumber.round == selectedRound)
        .toList();

    return ColoredBox(
      color: whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _RoundNavigator(
              selectedRound: selectedRound,
              canGoPrevious: canGoPrevious,
              canGoNext: canGoNext,
              onPrevious: () {
                setState(() {
                  selectedRound -= 1;
                });
              },
              onNext: () {
                setState(() {
                  selectedRound += 1;
                });
              },
            ),
          ),
          Expanded(
            child: _SavedNumbersList(
              savedNumbers: selectedRoundNumbers,
              emptyMessage: '$selectedRound회에 저장한 번호가 없습니다',
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundNavigator extends StatelessWidget {
  const _RoundNavigator({
    required this.selectedRound,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int selectedRound;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
        ),
        SizedBox(
          width: 120,
          child: Center(
            child: Text(
              '$selectedRound회',
              style: const TextStyle(
                color: blackColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canGoNext ? onNext : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _SavedNumbersList extends StatelessWidget {
  const _SavedNumbersList({
    required this.savedNumbers,
    required this.emptyMessage,
  });

  final List<SavedLottoNumber> savedNumbers;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (savedNumbers.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: greyColor,
            fontSize: 16,
          ),
        ),
      );
    }

    final reversedNumbers = savedNumbers.reversed.toList();

    return ListView.builder(
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
