import 'package:flutter/material.dart';
import 'package:randomlottonumber/data/num_history_mock.dart';
import 'package:randomlottonumber/models/lotto_winning_round.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/lotto_ball.dart';

class WinningHistoryView extends StatelessWidget {
  const WinningHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final reversedRounds = lottoWinningRounds.reversed.toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: reversedRounds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _WinningRoundCard(winningRound: reversedRounds[index]);
      },
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
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...winningRound.numbers.map(
                      (number) => HistoryNumberBall(number: number),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '+',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              HistoryNumberBall(number: winningRound.bonusNumber),
            ],
          ),
        ],
      ),
    );
  }
}
