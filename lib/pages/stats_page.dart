import 'package:flutter/material.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/lotto_number_frequency.dart';
import 'package:luckez/services/lotto_statistics_service.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/widgets/app_card.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/winning_history_view.dart';

enum _StatsView {
  frequency,
  history,
}

class StatsPage extends StatefulWidget {
  const StatsPage({
    super.key,
    required this.winningRounds,
    required this.isLoading,
    required this.hasError,
  });

  final List<LottoWinningRound> winningRounds;
  final bool isLoading;
  final bool hasError;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _statisticsService = LottoStatisticsService();

  _StatsView selectedView = _StatsView.history;
  bool includeBonusNumber = false;

  @override
  Widget build(BuildContext context) {
    final frequencies = widget.isLoading || widget.hasError
        ? <LottoNumberFrequency>[]
        : _statisticsService.calculateNumberFrequencies(
            rounds: widget.winningRounds,
            includeBonusNumber: includeBonusNumber,
          );
    final maxCount = frequencies.isEmpty ? 0 : frequencies.first.count;
    final isFrequencyView = selectedView == _StatsView.frequency;

    return ColoredBox(
      color: const Color(0xffF7F7F8),
      child: SafeArea(
        top: false,
        child: PageContentWidth(
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
                        _roundRangeLabel,
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
                child: _StatsBody(
                  isLoading: widget.isLoading,
                  hasError: widget.hasError,
                  isFrequencyView: isFrequencyView,
                  frequencies: frequencies,
                  maxCount: maxCount,
                  winningRounds: widget.winningRounds,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _roundRangeLabel {
    if (widget.isLoading) {
      return '당첨번호 불러오는 중';
    }

    if (widget.hasError) {
      return '당첨번호를 불러오지 못했어요';
    }

    if (widget.winningRounds.isEmpty) {
      return '당첨번호 데이터 없음';
    }

    return '${widget.winningRounds.first.round}회 ~ ${widget.winningRounds.last.round}회';
  }

  ButtonStyle get _segmentedButtonStyle {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? mainColor : whiteColor,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? whiteColor : blackColor,
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? mainColor
              : const Color(0xffE6E6E8),
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.isLoading,
    required this.hasError,
    required this.isFrequencyView,
    required this.frequencies,
    required this.maxCount,
    required this.winningRounds,
  });

  final bool isLoading;
  final bool hasError;
  final bool isFrequencyView;
  final List<LottoNumberFrequency> frequencies;
  final int maxCount;
  final List<LottoWinningRound> winningRounds;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _StatsSkeletonList();
    }

    if (hasError) {
      return const _StatsStateMessage(
        icon: Icons.cloud_off_outlined,
        message: '당첨번호를 불러오지 못했어요',
      );
    }

    if (winningRounds.isEmpty) {
      return const _StatsStateMessage(
        icon: Icons.info_outline,
        message: '당첨번호 데이터가 없어요',
      );
    }

    if (isFrequencyView) {
      return _NumberFrequencyList(
        frequencies: frequencies,
        maxCount: maxCount,
      );
    }

    return WinningHistoryView(winningRounds: winningRounds);
  }
}

class _StatsStateMessage extends StatelessWidget {
  const _StatsStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: greyColor,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSkeletonList extends StatelessWidget {
  const _StatsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _StatsSkeletonCard(),
    );
  }
}

class _StatsSkeletonCard extends StatelessWidget {
  const _StatsSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            _SkeletonBlock(width: 28, height: 14),
            SizedBox(width: 14),
            _SkeletonCircle(size: 38),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SkeletonBlock(height: 14),
                  SizedBox(height: 10),
                  _SkeletonBlock(height: 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffECECEF),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    this.width,
    required this.height,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xffECECEF),
          borderRadius: BorderRadius.circular(999),
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

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
