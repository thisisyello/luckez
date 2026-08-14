import 'package:flutter/material.dart';
import 'package:randomlottonumber/models/saved_lotto_number.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class MyNumbersPage extends StatefulWidget {
  const MyNumbersPage({
    super.key,
    required this.savedNumbers,
    required this.activeRound,
    required this.onTogglePurchased,
    required this.onDeleteSavedNumber,
  });

  final List<SavedLottoNumber> savedNumbers;
  final int activeRound;
  final ValueChanged<String> onTogglePurchased;
  final ValueChanged<String> onDeleteSavedNumber;

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
      color: const Color(0xffF7F7F8),
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
              onTogglePurchased: widget.onTogglePurchased,
              onDeleteSavedNumber: widget.onDeleteSavedNumber,
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
    required this.onTogglePurchased,
    required this.onDeleteSavedNumber,
  });

  final List<SavedLottoNumber> savedNumbers;
  final String emptyMessage;
  final ValueChanged<String> onTogglePurchased;
  final ValueChanged<String> onDeleteSavedNumber;

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
            border: Border.all(
              color:
                  savedNumber.isPurchased ? mainColor : const Color(0xffEEEEEE),
              width: savedNumber.isPurchased ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: savedNumber.isPurchased,
                      activeColor: mainColor,
                      onChanged: (_) => onTogglePurchased(savedNumber.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '구매 완료',
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _confirmDelete(
                      context,
                      savedNumber.id,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _formatCreatedAt(savedNumber.createdAt),
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('저장한 번호 삭제'),
          content: const Text('이 번호를 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      onDeleteSavedNumber(id);
    }
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
