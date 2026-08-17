import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luckez/constants/lotto_round.dart';
import 'package:luckez/data/num_history_mock.dart';
import 'package:luckez/models/lotto_round_info.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/repositories/saved_lotto_number_repository.dart';
import 'package:luckez/services/auth_service.dart';
import 'package:luckez/services/lotto_result_checker.dart';
import 'package:luckez/pages/community_page.dart';
import 'package:luckez/pages/lotto_draw_page.dart';
import 'package:luckez/pages/my_numbers_page.dart';
import 'package:luckez/pages/purchase_page.dart';
import 'package:luckez/pages/stats_page.dart';
import 'package:luckez/theme/app_colors.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static final _authService = AuthService();
  static final _savedNumberRepository = SavedLottoNumberRepository();
  static const _resultChecker = LottoResultChecker();

  int selectedIndex = 0;
  String? currentUserId;
  StreamSubscription<List<SavedLottoNumber>>? savedNumbersSubscription;
  LottoRoundInfo roundInfo = const LottoRoundInfo(
    activeRound: initialActiveRound,
    latestDrawRound: initialLatestDrawRound,
  );
  final List<SavedLottoNumber> savedNumbers = [];

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      final user = await _authService.signInAnonymouslyIfNeeded();

      if (!mounted) {
        return;
      }

      setState(() {
        currentUserId = user.uid;
      });
      _listenSavedNumbers(user.uid);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('로그인 연결을 확인해주세요');
    }
  }

  @override
  void dispose() {
    savedNumbersSubscription?.cancel();
    super.dispose();
  }

  void _listenSavedNumbers(String userId) {
    savedNumbersSubscription?.cancel();
    savedNumbersSubscription =
        _savedNumberRepository.watchSavedNumbers(userId).listen(
      (numbers) {
        if (!mounted) {
          return;
        }

        setState(() {
          savedNumbers
            ..clear()
            ..addAll(numbers);
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        _showComingSoonMessage('저장번호를 불러오지 못했어요');
      },
    );
  }

  Future<void> saveLottoNumbers(List<int> numbers) async {
    final userId = currentUserId;

    if (userId == null) {
      _showComingSoonMessage('로그인 연결을 확인해주세요');
      return;
    }

    final now = DateTime.now();
    final savedNumber = _applyWinningResult(
      SavedLottoNumber(
        id: now.microsecondsSinceEpoch.toString(),
        numbers: List<int>.from(numbers),
        createdAt: now,
        round: roundInfo.activeRound,
      ),
      checkedAt: now,
    );

    try {
      await _savedNumberRepository.save(userId, savedNumber);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('번호 저장에 실패했어요');
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('번호를 저장했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  SavedLottoNumber _applyWinningResult(
    SavedLottoNumber savedNumber, {
    required DateTime checkedAt,
  }) {
    final winningRound = _findWinningRound(savedNumber.round);

    if (winningRound == null) {
      return savedNumber;
    }

    final result = _resultChecker.check(
      savedNumber: savedNumber,
      winningRound: winningRound,
    );

    return savedNumber.copyWith(
      resultStatus: result.status,
      matchCount: result.matchCount,
      isBonusMatched: result.isBonusMatched,
      checkedAt: checkedAt,
    );
  }

  LottoWinningRound? _findWinningRound(int? round) {
    if (round == null) {
      return null;
    }

    for (final winningRound in lottoWinningRounds) {
      if (winningRound.round == round) {
        return winningRound;
      }
    }

    return null;
  }

  Future<void> togglePurchased(String id) async {
    final userId = currentUserId;
    final index =
        savedNumbers.indexWhere((savedNumber) => savedNumber.id == id);

    if (userId == null || index == -1) {
      return;
    }

    final savedNumber = savedNumbers[index];
    final updatedSavedNumber = savedNumber.copyWith(
      isPurchased: !savedNumber.isPurchased,
      updatedAt: DateTime.now(),
    );

    await _updateSavedNumber(userId, updatedSavedNumber);
  }

  Future<void> updateSavedNumbers(String id, List<int> numbers) async {
    final userId = currentUserId;
    final index =
        savedNumbers.indexWhere((savedNumber) => savedNumber.id == id);

    if (userId == null || index == -1) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final savedNumber = savedNumbers[index].copyWith(
      numbers: List<int>.from(numbers)..sort(),
      updatedAt: now,
    );
    final updatedSavedNumber = _applyWinningResult(
      savedNumber,
      checkedAt: now,
    );

    final isUpdated = await _updateSavedNumber(userId, updatedSavedNumber);

    if (!mounted || !isUpdated) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('저장한 번호를 수정했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<bool> _updateSavedNumber(
    String userId,
    SavedLottoNumber savedNumber,
  ) async {
    try {
      await _savedNumberRepository.update(userId, savedNumber);
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }

      _showComingSoonMessage('저장번호 수정에 실패했어요');
      return false;
    }
  }

  Future<void> deleteSavedNumber(String id) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _savedNumberRepository.delete(userId, id);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('저장번호 삭제에 실패했어요');
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장한 번호를 삭제했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          LottoDrawPage(
            savedNumbersCount: savedNumbers.length,
            onSaveNumbers: saveLottoNumbers,
          ),
          const StatsPage(),
          const PurchasePage(),
          MyNumbersPage(
            savedNumbers: savedNumbers,
            activeRound: roundInfo.activeRound,
            onTogglePurchased: togglePurchased,
            onUpdateSavedNumbers: updateSavedNumbers,
            onDeleteSavedNumber: deleteSavedNumber,
          ),
          const CommunityPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: mainColor.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: _PurchaseTabIcon(isSelected: false),
            selectedIcon: _PurchaseTabIcon(isSelected: true),
            label: '구매',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: '내 번호',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.person_outline),
        color: blackColor,
        onPressed: () => _showUserStatus(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          color: blackColor,
          onPressed: () => _showComingSoonMessage('알림 기능 준비 중'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showUserStatus() {
    final message = currentUserId == null ? '익명 로그인 확인 중' : '익명 사용자로 연결됐어요';
    _showComingSoonMessage(message);
  }

  void _showComingSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _PurchaseTabIcon extends StatelessWidget {
  const _PurchaseTabIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? mainColor : mainColor.withOpacity(0.12),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 20,
        color: isSelected ? whiteColor : mainColor,
      ),
    );
  }
}
