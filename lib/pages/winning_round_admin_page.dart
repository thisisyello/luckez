import 'package:flutter/material.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/services/lotto_round_date_service.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';

class WinningRoundAdminPage extends StatefulWidget {
  const WinningRoundAdminPage({
    super.key,
    required this.initialRound,
    required this.onSubmit,
  });

  final int initialRound;
  final Future<void> Function(LottoWinningRound winningRound) onSubmit;

  @override
  State<WinningRoundAdminPage> createState() => _WinningRoundAdminPageState();
}

class _WinningRoundAdminPageState extends State<WinningRoundAdminPage> {
  static final _roundDateService = LottoRoundDateService();

  late final TextEditingController _roundController;
  late final TextEditingController _numbersController;
  late final TextEditingController _bonusController;
  late final TextEditingController _drawDateController;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();

    _roundController =
        TextEditingController(text: widget.initialRound.toString());
    _numbersController = TextEditingController();
    _bonusController = TextEditingController();
    _drawDateController = TextEditingController(
      text: _formatDate(_roundDateService.getDrawDate(widget.initialRound)),
    );
  }

  @override
  void dispose() {
    _roundController.dispose();
    _numbersController.dispose();
    _bonusController.dispose();
    _drawDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '당첨번호 등록',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const _NoticeCard(),
              const SizedBox(height: 14),
              _AdminTextField(
                controller: _roundController,
                label: '회차',
                hintText: '1238',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _numbersController,
                label: '당첨번호 6개',
                hintText: '3, 11, 18, 24, 37, 42',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _bonusController,
                label: '보너스 번호',
                hintText: '7',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _drawDateController,
                label: '추첨일',
                hintText: '2026.08.22',
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: whiteColor,
                    disabledBackgroundColor: const Color(0xffE6E6E8),
                    disabledForegroundColor: greyColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(_isSaving ? '등록 중' : '등록하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final round = int.tryParse(_roundController.text.trim());
    final numbers = _parseNumbers(_numbersController.text);
    final bonusNumber = int.tryParse(_bonusController.text.trim());
    final drawDate = _parseDate(_drawDateController.text.trim());

    final errorMessage = _validate(
      round: round,
      numbers: numbers,
      bonusNumber: bonusNumber,
      drawDate: drawDate,
    );

    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(
        LottoWinningRound(
          round: round!,
          numbers: List<int>.from(numbers)..sort(),
          bonusNumber: bonusNumber!,
          drawDate: drawDate,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      _showMessage('당첨번호 등록에 실패했어요');
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  List<int> _parseNumbers(String value) {
    return value
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map(int.parse)
        .toList();
  }

  DateTime? _parseDate(String value) {
    final match =
        RegExp(r'^(\d{4})[-.](\d{1,2})[-.](\d{1,2})$').firstMatch(value);

    if (match == null) {
      return null;
    }

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  String? _validate({
    required int? round,
    required List<int> numbers,
    required int? bonusNumber,
    required DateTime? drawDate,
  }) {
    if (round == null || round <= 0) {
      return '회차를 확인해주세요';
    }

    if (numbers.length != 6) {
      return '당첨번호는 6개를 입력해주세요';
    }

    if (numbers.any((number) => number < 1 || number > 45)) {
      return '번호는 1부터 45까지만 입력할 수 있어요';
    }

    if (numbers.toSet().length != numbers.length) {
      return '당첨번호에 중복이 있어요';
    }

    if (bonusNumber == null || bonusNumber < 1 || bonusNumber > 45) {
      return '보너스 번호를 확인해주세요';
    }

    if (numbers.contains(bonusNumber)) {
      return '보너스 번호가 당첨번호와 중복돼요';
    }

    if (drawDate == null) {
      return '추첨일은 2026.08.22 형식으로 입력해주세요';
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: const Text(
        '임시 등록 화면입니다. 회원 등급 구조가 생기면 관리자만 접근하도록 바꿀 예정입니다.',
        style: TextStyle(
          color: greyColor,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  const _AdminTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffE6E6E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffE6E6E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mainColor, width: 1.4),
        ),
      ),
    );
  }
}
