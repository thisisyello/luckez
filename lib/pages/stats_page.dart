import 'package:flutter/material.dart';
import 'package:randomlottonumber/data/num_history_mock.dart';
import 'package:randomlottonumber/models/lotto_number_frequency.dart';
import 'package:randomlottonumber/services/lotto_statistics_service.dart';
import 'package:randomlottonumber/theme/app_colors.dart';
import 'package:randomlottonumber/widgets/winning_history_view.dart';

enum _StatsView {
  frequency,
  history,
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _statisticsService = LottoStatisticsService();

  _StatsView selectedView = _StatsView.frequency;
  bool includeBonusNumber = false;

  @override
  Widget build(BuildContext context) {
    final frequencies = _statisticsService.calculateNumberFrequencies(
      rounds: lottoWinningRounds,
      includeBonusNumber: includeBonusNumber,
    );
    final maxCount = frequencies.first.count;
    final isFrequencyView = selectedView == _StatsView.frequency;

    return ColoredBox(
      color: const Color(0xffF7F7F8),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsViewSwitcher(
                    selectedView: selectedView,
                    onChanged: (view) {
                      setState(() {
                        selectedView = view;
                      });
                    },
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '${lottoWinningRounds.first.round}회 ~ ${lottoWinningRounds.last.round}회',
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isFrequencyView) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.filter_6_outlined),
                          label: Text('보너스 제외'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.add_circle_outline),
                          label: Text('보너스 포함'),
                        ),
                      ],
                      selected: {includeBonusNumber},
                      style: _segmentedButtonStyle,
                      onSelectionChanged: (selection) {
                        setState(() {
                          includeBonusNumber = selection.first;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: isFrequencyView
                  ? _NumberFrequencyList(
                      frequencies: frequencies,
                      maxCount: maxCount,
                    )
                  : const WinningHistoryView(),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle get _segmentedButtonStyle {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith(
        (states) =>
            states.contains(MaterialState.selected) ? mainColor : blackColor,
      ),
      side: MaterialStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(MaterialState.selected)
              ? mainColor
              : const Color(0xffE6E6E8),
        ),
      ),
    );
  }
}

class _StatsViewSwitcher extends StatelessWidget {
  const _StatsViewSwitcher({
    required this.selectedView,
    required this.onChanged,
  });

  final _StatsView selectedView;
  final ValueChanged<_StatsView> onChanged;

  @override
  Widget build(BuildContext context) {
    final title = selectedView == _StatsView.frequency ? '출현 순위' : '역대 당첨번호';
    final nextView = selectedView == _StatsView.frequency
        ? _StatsView.history
        : _StatsView.frequency;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => onChanged(nextView),
          icon: const Icon(Icons.chevron_left),
          color: blackColor,
          iconSize: 30,
        ),
        SizedBox(
          width: 168,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: blackColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(nextView),
          icon: const Icon(Icons.chevron_right),
          color: blackColor,
          iconSize: 30,
        ),
      ],
    );
  }
}

class _NumberFrequencyList extends StatelessWidget {
  const _NumberFrequencyList({
    required this.frequencies,
    required this.maxCount,
  });

  final List<LottoNumberFrequency> frequencies;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: frequencies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _NumberFrequencyCard(
          frequency: frequencies[index],
          maxCount: maxCount,
        );
      },
    );
  }
}

class _NumberFrequencyCard extends StatelessWidget {
  const _NumberFrequencyCard({
    required this.frequency,
    required this.maxCount,
  });

  final LottoNumberFrequency frequency;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final progress = maxCount == 0 ? 0.0 : frequency.count / maxCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${frequency.rank}',
              style: const TextStyle(
                color: greyColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _NumberBadge(number: frequency.number),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${frequency.number}번',
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${frequency.count}회',
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xffEFEFF1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getTextColor(frequency.number),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: getTextColor(number),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: whiteColor,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
