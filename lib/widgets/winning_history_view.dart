import 'package:flutter/material.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/lotto_ball.dart';

class WinningHistoryView extends StatelessWidget {
  const WinningHistoryView({
    super.key,
    required this.winningRounds,
  });

  final List<LottoWinningRound> winningRounds;

  @override
  Widget build(BuildContext context) {
    final reversedRounds = winningRounds.reversed.toList();

    return PageContentWidth(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: reversedRounds.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _WinningRoundCard(winningRound: reversedRounds[index]);
        },
      ),
    );
  }
}

class _WinningRoundCard extends StatelessWidget {
  const _WinningRoundCard({required this.winningRound});

  final LottoWinningRound winningRound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${winningRound.round}회 당첨번호',
            style: const TextStyle(
              color: blackColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...winningRound.numbers.map(
                (number) => HistoryNumberBall(number: number),
              ),
              // Expanded(
              //   child: Row(
              //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //     ],
              //   ),
              // ),
              // const SizedBox(width: 24),
              const Text(
                '+',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              // const SizedBox(width: 24),
              HistoryNumberBall(number: winningRound.bonusNumber),
            ],
          ),
        ],
      ),
    );
  }
}
