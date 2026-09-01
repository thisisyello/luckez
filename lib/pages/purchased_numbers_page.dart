import 'package:flutter/material.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';
import 'package:luckez/widgets/lotto_ball.dart';

class PurchasedNumbersPage extends StatelessWidget {
  const PurchasedNumbersPage({
    super.key,
    required this.savedNumbers,
  });

  final List<SavedLottoNumber> savedNumbers;

  @override
  Widget build(BuildContext context) {
    final purchasedNumbers = savedNumbers
        .where((savedNumber) => savedNumber.isPurchased)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '구매한 번호',
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
          child: purchasedNumbers.isEmpty
              ? const _PurchasedNumbersEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  itemCount: purchasedNumbers.length,
                  itemBuilder: (context, index) {
                    final savedNumber = purchasedNumbers[index];

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      showShadow: false,
                      isSelected: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                savedNumber.round == null
                                    ? '회차 정보 없음'
                                    : '${savedNumber.round}회',
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_formatDate(savedNumber.createdAt)} 저장',
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: savedNumber.numbers
                                .map(
                                  (number) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: LottoBall(number: number),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
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

class _PurchasedNumbersEmpty extends StatelessWidget {
  const _PurchasedNumbersEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: greyColor,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            '구매 완료한 번호가 없어요',
            style: TextStyle(
              color: greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
