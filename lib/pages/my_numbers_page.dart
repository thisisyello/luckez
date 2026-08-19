import 'package:flutter/material.dart';
import 'package:luckez/models/lotto_result_status.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/services/lotto_round_date_service.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/lotto_ball.dart';

typedef SavedNumbersUpdated = void Function(String id, List<int> numbers);

class MyNumbersPage extends StatefulWidget {
  const MyNumbersPage({
    super.key,
    required this.savedNumbers,
    required this.activeRound,
    required this.onTogglePurchased,
    required this.onUpdateSavedNumbers,
    required this.onDeleteSavedNumber,
  });

  final List<SavedLottoNumber> savedNumbers;
  final int activeRound;
  final ValueChanged<String> onTogglePurchased;
  final SavedNumbersUpdated onUpdateSavedNumbers;
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

  static const minSelectableRound = 1;

  bool get canGoPrevious => selectedRound > minSelectableRound;
  bool get canGoNext => selectedRound < widget.activeRound;

  @override
  Widget build(BuildContext context) {
    final selectedRoundNumbers = widget.savedNumbers
        .where((savedNumber) => savedNumber.round == selectedRound)
        .toList();

    return ColoredBox(
      color: const Color(0xffF7F7F8),
      child: PageContentWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _RoundNavigator(
                selectedRound: selectedRound,
                latestDrawRound: widget.activeRound - 1,
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
                onRoundPressed: _showRoundPicker,
              ),
            ),
            Expanded(
              child: _SavedNumbersList(
                savedNumbers: selectedRoundNumbers,
                emptyMessage: '$selectedRound회에 저장한 번호가 없습니다',
                onTogglePurchased: widget.onTogglePurchased,
                onUpdateSavedNumbers: widget.onUpdateSavedNumbers,
                onDeleteSavedNumber: widget.onDeleteSavedNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRoundPicker() async {
    final round = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return _RoundPickerSheet(
          initialRound: selectedRound,
          minRound: minSelectableRound,
          maxRound: widget.activeRound,
        );
      },
    );

    if (round == null) {
      return;
    }

    setState(() {
      selectedRound = round;
    });
  }
}

class _RoundNavigator extends StatelessWidget {
  const _RoundNavigator({
    required this.selectedRound,
    required this.latestDrawRound,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onRoundPressed,
  });

  static const _roundDateService = LottoRoundDateService();

  final int selectedRound;
  final int latestDrawRound;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRoundPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: canGoNext ? onNext : null,
              icon: const Icon(Icons.chevron_left),
            ),
            SizedBox(
              width: 120,
              child: TextButton(
                onPressed: onRoundPressed,
                style: TextButton.styleFrom(
                  foregroundColor: blackColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('$selectedRound회'),
              ),
            ),
            IconButton(
              onPressed: canGoPrevious ? onPrevious : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Text(
          _roundDateService.getDrawDateLabel(
            round: selectedRound,
            latestDrawRound: latestDrawRound,
          ),
          style: const TextStyle(
            color: greyColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoundPickerSheet extends StatefulWidget {
  const _RoundPickerSheet({
    required this.initialRound,
    required this.minRound,
    required this.maxRound,
  });

  final int initialRound;
  final int minRound;
  final int maxRound;

  @override
  State<_RoundPickerSheet> createState() => _RoundPickerSheetState();
}

class _RoundPickerSheetState extends State<_RoundPickerSheet> {
  late final TextEditingController controller;
  String? errorText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialRound.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final sheetHeight = mediaQuery.size.height * 0.5;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: sheetHeight,
        child: Container(
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: PageContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '회차 선택',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        suffixText: '회',
                        filled: true,
                        fillColor: const Color(0xffF7F7F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: mainColor),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: redColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: whiteColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('이동'),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => Navigator.pop(context, widget.maxRound),
                      style: TextButton.styleFrom(
                        foregroundColor: greyColor,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('현재 회차로 이동'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final round = int.tryParse(controller.text.trim());

    if (round == null || round < widget.minRound || round > widget.maxRound) {
      setState(() {
        errorText = '${widget.minRound}회부터 ${widget.maxRound}회까지 입력해주세요';
      });
      return;
    }

    Navigator.pop(context, round);
  }
}

class _SavedNumbersList extends StatelessWidget {
  const _SavedNumbersList({
    required this.savedNumbers,
    required this.emptyMessage,
    required this.onTogglePurchased,
    required this.onUpdateSavedNumbers,
    required this.onDeleteSavedNumber,
  });

  final List<SavedLottoNumber> savedNumbers;
  final String emptyMessage;
  final ValueChanged<String> onTogglePurchased;
  final SavedNumbersUpdated onUpdateSavedNumbers;
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
                    onPressed: () => _showEditDialog(
                      context,
                      savedNumber,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    visualDensity: VisualDensity.compact,
                  ),
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
              _ResultSummary(savedNumber: savedNumber),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    SavedLottoNumber savedNumber,
  ) async {
    final updatedNumbers = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        return _EditSavedNumbersDialog(numbers: savedNumber.numbers);
      },
    );

    if (updatedNumbers == null) {
      return;
    }

    onUpdateSavedNumbers(savedNumber.id, updatedNumbers);
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
}

class _EditSavedNumbersDialog extends StatefulWidget {
  const _EditSavedNumbersDialog({required this.numbers});

  final List<int> numbers;

  @override
  State<_EditSavedNumbersDialog> createState() =>
      _EditSavedNumbersDialogState();
}

class _EditSavedNumbersDialogState extends State<_EditSavedNumbersDialog> {
  late final List<TextEditingController> controllers;
  String? errorText;

  @override
  void initState() {
    super.initState();
    controllers = [
      for (final number in widget.numbers)
        TextEditingController(text: number.toString().padLeft(2, '0')),
    ];
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('저장번호 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final controller in controllers)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: const InputDecoration(
                        counterText: '',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              style: const TextStyle(
                color: redColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _submit() {
    final numbers = <int>[];

    for (final controller in controllers) {
      final number = int.tryParse(controller.text.trim());

      if (number == null || number < 1 || number > 45) {
        setState(() {
          errorText = '번호는 1부터 45까지 입력해주세요';
        });
        return;
      }

      numbers.add(number);
    }

    if (numbers.toSet().length != numbers.length) {
      setState(() {
        errorText = '중복되지 않는 번호 6개를 입력해주세요';
      });
      return;
    }

    numbers.sort();
    Navigator.pop(context, numbers);
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.savedNumber});

  final SavedLottoNumber savedNumber;

  @override
  Widget build(BuildContext context) {
    final resultColor = _resultStatusColor(savedNumber.resultStatus);
    final detailText = _resultDetailText(savedNumber);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: resultColor.withOpacity(0.28)),
              ),
              child: Text(
                _resultStatusLabel(savedNumber.resultStatus),
                style: TextStyle(
                  color: resultColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (detailText != null) ...[
              const SizedBox(width: 8),
              Text(
                detailText,
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _formatCreatedAt(savedNumber.createdAt),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: greyColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String? _resultDetailText(SavedLottoNumber savedNumber) {
    if (savedNumber.resultStatus == LottoResultStatus.pending ||
        savedNumber.matchCount == null) {
      return null;
    }

    final bonusText = savedNumber.isBonusMatched == true ? ' + 보너스' : '';
    return '${savedNumber.matchCount}개 일치$bonusText';
  }

  Color _resultStatusColor(LottoResultStatus status) {
    switch (status) {
      case LottoResultStatus.pending:
        return greyColor;
      case LottoResultStatus.notWon:
        return const Color(0xff6B7280);
      case LottoResultStatus.fifth:
      case LottoResultStatus.fourth:
        return const Color(0xff2563EB);
      case LottoResultStatus.third:
      case LottoResultStatus.second:
        return const Color(0xff7C3AED);
      case LottoResultStatus.first:
        return mainColor;
    }
  }

  String _resultStatusLabel(LottoResultStatus status) {
    switch (status) {
      case LottoResultStatus.pending:
        return '추첨 전';
      case LottoResultStatus.notWon:
        return '낙첨';
      case LottoResultStatus.fifth:
        return '5등';
      case LottoResultStatus.fourth:
        return '4등';
      case LottoResultStatus.third:
        return '3등';
      case LottoResultStatus.second:
        return '2등';
      case LottoResultStatus.first:
        return '1등';
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
