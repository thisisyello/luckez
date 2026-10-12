import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckez/controllers/saved_numbers_controller.dart';
import 'package:luckez/controllers/session_controller.dart';
import 'package:luckez/controllers/winning_rounds_controller.dart';
import 'package:luckez/models/lotto_round_info.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/repositories/notification_repository.dart';
import 'package:luckez/services/auth_service.dart';
import 'package:luckez/pages/account_page.dart';
import 'package:luckez/pages/community_page.dart';
import 'package:luckez/pages/lotto_draw_page.dart';
import 'package:luckez/pages/my_numbers_page.dart';
import 'package:luckez/pages/notification_page.dart';
import 'package:luckez/pages/purchase_page.dart';
import 'package:luckez/pages/stats_page.dart';
import 'package:luckez/theme/app_colors.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final _sessionController = SessionController();
  final _savedNumbersController = SavedNumbersController();
  static final _communityRepository = CommunityRepository();
  static final _notificationRepository = NotificationRepository();
  final _winningRoundsController = WinningRoundsController();

  int selectedIndex = 0;
  String? get currentUserId => _sessionController.userId;
  String? _subscribedUserId;
  int _sessionErrorRevision = 0;
  int _savedNumbersErrorRevision = 0;
  StreamSubscription<int>? unreadNotificationsSubscription;
  LottoRoundInfo get roundInfo => _winningRoundsController.roundInfo;
  List<SavedLottoNumber> get savedNumbers => _savedNumbersController.numbers;
  List<LottoWinningRound> get winningRounds => _winningRoundsController.rounds;
  bool get isWinningRoundsLoading => _winningRoundsController.isLoading;
  bool get hasWinningRoundsError => _winningRoundsController.hasError;
  bool _wasWinningRoundsError = false;
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _savedNumbersController.addListener(_onSavedNumbersChanged);
    _sessionController.addListener(_onSessionChanged);
    _sessionController.start();
    _winningRoundsController.addListener(_onWinningRoundsChanged);
    _winningRoundsController.start();
  }

  void _onWinningRoundsChanged() {
    if (!mounted) return;
    if (hasWinningRoundsError && !_wasWinningRoundsError) {
      _showComingSoonMessage('당첨번호를 불러오지 못했어요');
    }
    _wasWinningRoundsError = hasWinningRoundsError;
    setState(() {});
  }

  void _onSessionChanged() {
    if (!mounted) return;
    final userId = currentUserId;
    if (_subscribedUserId != userId) {
      _subscribedUserId = userId;
      _savedNumbersController.bindUser(userId);
      unreadNotificationsSubscription?.cancel();
      unreadNotificationsSubscription = null;
      unreadNotificationsCount = 0;
      if (userId != null) {
        _listenUnreadNotifications(userId);
      }
    }
    if (_sessionErrorRevision != _sessionController.errorRevision) {
      _sessionErrorRevision = _sessionController.errorRevision;
      final message = _sessionController.errorMessage;
      if (message != null) _showComingSoonMessage(message);
    }
    setState(() {});
  }

  void _onSavedNumbersChanged() {
    if (!mounted) return;
    if (_savedNumbersErrorRevision != _savedNumbersController.errorRevision) {
      _savedNumbersErrorRevision = _savedNumbersController.errorRevision;
      if (_savedNumbersController.hasError) {
        _showComingSoonMessage('저장번호를 불러오지 못했어요');
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    _sessionController.dispose();
    _savedNumbersController.removeListener(_onSavedNumbersChanged);
    _savedNumbersController.dispose();
    _winningRoundsController.removeListener(_onWinningRoundsChanged);
    _winningRoundsController.dispose();
    unreadNotificationsSubscription?.cancel();
    super.dispose();
  }

  void _listenUnreadNotifications(String userId) {
    unreadNotificationsSubscription?.cancel();
    unreadNotificationsSubscription =
        _notificationRepository.watchUnreadCount(userId).listen(
      (count) {
        if (!mounted || currentUserId != userId) {
          return;
        }

        setState(() {
          unreadNotificationsCount = count;
        });
      },
      onError: (_) {
        if (!mounted || currentUserId != userId) {
          return;
        }

        setState(() {
          unreadNotificationsCount = 0;
        });
      },
    );
  }

  Future<void> saveLottoNumbers(List<int> numbers) async {
    final userId = currentUserId;

    if (userId == null) {
      _showComingSoonMessage('번호 저장은 로그인이 필요해요');
      _openAccountPage();
      return;
    }

    try {
      final saved = await _savedNumbersController.save(
        numbers,
        round: roundInfo.activeRound,
        winningRound: _findWinningRound(roundInfo.activeRound),
      );
      if (!saved) return;
    } catch (_) {
      if (!mounted || currentUserId != userId) {
        return;
      }

      _showComingSoonMessage('번호 저장에 실패했어요');
      return;
    }

    if (!mounted || currentUserId != userId) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('번호를 저장했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  LottoWinningRound? _findWinningRound(int? round) {
    return _winningRoundsController.findRound(round);
  }

  Future<void> togglePurchased(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _savedNumbersController.togglePurchased(id);
    } catch (_) {
      if (!mounted || currentUserId != userId) return;
      _showComingSoonMessage('저장번호 수정에 실패했어요');
    }
  }

  Future<void> updateSavedNumbers(String id, List<int> numbers) async {
    final userId = currentUserId;
    if (userId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await _savedNumbersController.updateNumbers(
        id,
        numbers,
        winningRound: _findWinningRound(_savedNumbersController.roundFor(id)),
      );
      if (!updated) return;
    } catch (_) {
      if (!mounted || currentUserId != userId) return;
      _showComingSoonMessage('저장번호 수정에 실패했어요');
      return;
    }
    if (!mounted || currentUserId != userId) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('저장한 번호를 수정했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> deleteSavedNumber(String id) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      final deleted = await _savedNumbersController.delete(id);
      if (!deleted) return;
    } catch (_) {
      if (!mounted || currentUserId != userId) {
        return;
      }

      _showComingSoonMessage('저장번호 삭제에 실패했어요');
      return;
    }

    if (!mounted || currentUserId != userId) {
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
          StatsPage(
            winningRounds: winningRounds,
            isLoading: isWinningRoundsLoading,
            hasError: hasWinningRoundsError,
          ),
          const PurchasePage(),
          currentUserId == null
              ? AccountPageContent(
                  isLoggedIn: false,
                  savedNumbersCount: savedNumbers.length,
                  purchasedNumbersCount: _purchasedNumbersCount,
                  savedNumbers: const [],
                  currentUserId: null,
                  currentUserName: null,
                  currentUserEmail: null,
                  currentUserPhotoUrl: null,
                  isAdmin: false,
                  onGooglePressed: _signInWithGoogle,
                  onEmailLoginPressed: _signInWithEmail,
                  onEmailSignUpPressed: _signUpWithEmail,
                  useBottomSafeArea: false,
                )
              : MyNumbersPage(
                  savedNumbers: savedNumbers,
                  activeRound: roundInfo.activeRound,
                  onTogglePurchased: togglePurchased,
                  onUpdateSavedNumbers: updateSavedNumbers,
                  onDeleteSavedNumber: deleteSavedNumber,
                ),
          CommunityPage(
            currentUserId: currentUserId,
            currentUserName: _currentUserName,
            isAdmin: _isAdmin,
            onLoginRequired: () {
              _showComingSoonMessage('커뮤니티 글쓰기는 로그인이 필요해요');
              _openAccountPage();
            },
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.72),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            height: 68,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: mainColor.withValues(alpha: 0.1),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
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
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
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
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: _ProfileIcon(photoUrl: _currentUserPhotoUrl),
        color: textPrimaryColor,
        tooltip: '계정',
        onPressed: _openAccountPage,
      ),
      actions: [
        IconButton(
          icon: _NotificationIcon(unreadCount: unreadNotificationsCount),
          color: textPrimaryColor,
          tooltip: '알림',
          onPressed: _openNotificationPage,
        ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }

  int get _purchasedNumbersCount => _savedNumbersController.purchasedCount;

  String? get _currentUserName => _sessionController.displayName;

  String? get _currentUserEmail => _sessionController.email;

  String? get _currentUserPhotoUrl => _sessionController.photoUrl;

  bool get _isAdmin => _sessionController.isAdmin;

  bool _isWinningRoundRegistered(int round) {
    return _findWinningRound(round) != null;
  }

  void _openNotificationPage() {
    final userId = currentUserId;

    if (userId == null) {
      _showComingSoonMessage('알림은 로그인이 필요해요');
      _openAccountPage();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationPage(
          userId: userId,
          currentUserName: _currentUserName,
          isAdmin: _isAdmin,
          notificationRepository: _notificationRepository,
          communityRepository: _communityRepository,
          onLoginRequired: () {
            _showComingSoonMessage('로그인이 필요해요');
            _openAccountPage();
          },
          onSavedNumberNotificationPressed: _openMyNumbersTabFromNotification,
        ),
      ),
    );
  }

  void _openMyNumbersTabFromNotification() {
    Navigator.of(context).maybePop();

    setState(() {
      selectedIndex = 3;
    });
  }

  void _openAccountPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountPage(
          isLoggedIn: currentUserId != null,
          savedNumbersCount: savedNumbers.length,
          purchasedNumbersCount: _purchasedNumbersCount,
          savedNumbers: List<SavedLottoNumber>.unmodifiable(savedNumbers),
          currentUserId: currentUserId,
          currentUserName: _currentUserName,
          currentUserEmail: _currentUserEmail,
          currentUserPhotoUrl: _currentUserPhotoUrl,
          isAdmin: _isAdmin,
          onGooglePressed: _signInWithGoogle,
          onEmailLoginPressed: _signInWithEmail,
          onEmailSignUpPressed: _signUpWithEmail,
          onDisplayNameSubmit: _updateDisplayName,
          onSavedNumbersPressed:
              currentUserId == null ? null : _openMyNumbersTabFromAccount,
          onSignOutPressed: currentUserId == null ? null : _signOut,
          onWinningRoundSubmit: _isAdmin ? _saveWinningRound : null,
          initialWinningRound: _isAdmin ? roundInfo.latestDrawRound + 1 : null,
          isWinningRoundRegistered: _isAdmin ? _isWinningRoundRegistered : null,
        ),
      ),
    );
  }

  Future<void> _updateDisplayName(String displayName) async {
    final userId = currentUserId;

    if (userId == null) {
      _showComingSoonMessage('로그인이 필요해요');
      return;
    }

    await _sessionController.updateDisplayName(displayName);
  }

  void _openMyNumbersTabFromAccount() {
    Navigator.of(context).maybePop();

    setState(() {
      selectedIndex = 3;
    });
  }

  Future<void> _signOut() async {
    try {
      await _sessionController.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('로그아웃에 실패했어요');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await _sessionController.signInWithGoogle();

      if (!mounted) {
        return;
      }

      _closeAccountFlow();
      _showComingSoonMessage('Google 계정으로 로그인됐어요');
    } on AuthCancelledException {
      return;
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage(_authErrorMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('Google 로그인에 실패했어요');
    }
  }

  Future<void> _signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showComingSoonMessage('이메일과 비밀번호를 입력해주세요');
      return;
    }

    try {
      await _sessionController.signInWithEmail(email, password);

      if (!mounted) {
        return;
      }

      _closeAccountFlow();
      _showComingSoonMessage('로그인됐어요');
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage(_authErrorMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('로그인에 실패했어요');
    }
  }

  Future<void> _signUpWithEmail(
    String displayName,
    String email,
    String password,
  ) async {
    if (displayName.trim().isEmpty) {
      _showComingSoonMessage('이름을 입력해주세요');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _showComingSoonMessage('이메일과 비밀번호를 입력해주세요');
      return;
    }

    try {
      await _sessionController.signUpWithEmail(displayName, email, password);

      if (!mounted) {
        return;
      }

      _closeAccountFlow();
      _showComingSoonMessage('회원가입이 완료됐어요');
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage(_authErrorMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('회원가입에 실패했어요');
    }
  }

  void _closeAccountFlow() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveWinningRound(LottoWinningRound winningRound) async {
    final userId = currentUserId;
    final isExistingRound = _findWinningRound(winningRound.round) != null;

    try {
      await _winningRoundsController.saveWinningRound(winningRound);

      if (userId != null && currentUserId == userId) {
        await _refreshSavedNumberResultsForRound(userId, winningRound);
      }
    } catch (_) {
      rethrow;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isExistingRound
              ? '${winningRound.round}회 당첨번호를 수정했어요'
              : '${winningRound.round}회 당첨번호를 등록했어요',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _refreshSavedNumberResultsForRound(
    String userId,
    LottoWinningRound winningRound,
  ) async {
    final summary = await _savedNumbersController.refreshResults(winningRound);
    if (!mounted || currentUserId != userId || summary == null) return;

    await _notificationRepository.createWinningResultNotification(
      userId: userId,
      round: winningRound.round,
      savedNumbersCount: summary.savedNumbersCount,
      bestResultStatus: summary.bestResultStatus,
    );
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return '이메일 형식을 확인해주세요';
      case 'user-disabled':
        return '사용할 수 없는 계정입니다';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호를 확인해주세요';
      case 'email-already-in-use':
        return '이미 가입된 이메일입니다';
      case 'weak-password':
        return '비밀번호는 6자 이상으로 입력해주세요';
      case 'too-many-requests':
        return '잠시 후 다시 시도해주세요';
      default:
        return '인증 처리에 실패했어요';
    }
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

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final label = unreadCount > 99 ? '99+' : unreadCount.toString();

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none,
              size: 22,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: surfaceColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xffF3F3F5),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return const Icon(
      Icons.account_circle_outlined,
      size: 25,
    );
  }
}
