import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckez/constants/lotto_round.dart';
import 'package:luckez/models/lotto_round_info.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/models/user_profile.dart';
import 'package:luckez/repositories/notification_repository.dart';
import 'package:luckez/repositories/saved_lotto_number_repository.dart';
import 'package:luckez/repositories/user_repository.dart';
import 'package:luckez/repositories/winning_round_repository.dart';
import 'package:luckez/services/auth_service.dart';
import 'package:luckez/services/lotto_result_checker.dart';
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
  static final _authService = AuthService();
  static final _savedNumberRepository = SavedLottoNumberRepository();
  static final _notificationRepository = NotificationRepository();
  static final _userRepository = UserRepository();
  static final _winningRoundRepository = WinningRoundRepository();
  static const _resultChecker = LottoResultChecker();

  int selectedIndex = 0;
  String? currentUserId;
  StreamSubscription<User?>? authSubscription;
  StreamSubscription<List<SavedLottoNumber>>? savedNumbersSubscription;
  StreamSubscription<List<LottoWinningRound>>? winningRoundsSubscription;
  StreamSubscription<UserProfile>? userProfileSubscription;
  StreamSubscription<int>? unreadNotificationsSubscription;
  LottoRoundInfo roundInfo = const LottoRoundInfo(
    activeRound: initialActiveRound,
    latestDrawRound: initialLatestDrawRound,
  );
  final List<SavedLottoNumber> savedNumbers = [];
  List<LottoWinningRound> winningRounds = [];
  bool isWinningRoundsLoading = true;
  bool hasWinningRoundsError = false;
  String currentUserRole = 'user';
  int unreadNotificationsCount = 0;
  UserProfile? currentUserProfile;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _listenAuthState();
    _listenWinningRounds();
  }

  void _listenWinningRounds() {
    winningRoundsSubscription?.cancel();
    winningRoundsSubscription =
        _winningRoundRepository.watchWinningRounds().listen(
      (rounds) {
        if (!mounted || rounds.isEmpty) {
          return;
        }

        setState(() {
          winningRounds = rounds;
          isWinningRoundsLoading = false;
          hasWinningRoundsError = false;
          roundInfo = roundInfo.copyWith(
            activeRound: rounds.last.round + 1,
            latestDrawRound: rounds.last.round,
          );
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        _showComingSoonMessage('당첨번호를 불러오지 못했어요');
        setState(() {
          winningRounds = [];
          isWinningRoundsLoading = false;
          hasWinningRoundsError = true;
        });
      },
    );
  }

  void _listenAuthState() {
    authSubscription?.cancel();
    authSubscription = _authService.authStateChanges.listen((user) {
      if (!mounted) {
        return;
      }

      setState(() {
        currentUser = user;
        currentUserId = user?.uid;

        if (user == null) {
          savedNumbers.clear();
          currentUserRole = 'user';
          currentUserProfile = null;
          unreadNotificationsCount = 0;
        }
      });

      if (user == null) {
        savedNumbersSubscription?.cancel();
        savedNumbersSubscription = null;
        userProfileSubscription?.cancel();
        userProfileSubscription = null;
        unreadNotificationsSubscription?.cancel();
        unreadNotificationsSubscription = null;
        return;
      }

      _ensureUserProfile(user);
      _listenUserProfile(user.uid);
      _listenSavedNumbers(user.uid);
      _listenUnreadNotifications(user.uid);
    });
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    savedNumbersSubscription?.cancel();
    winningRoundsSubscription?.cancel();
    userProfileSubscription?.cancel();
    unreadNotificationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      await _userRepository.ensureUserProfile(user);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showComingSoonMessage('회원 정보를 동기화하지 못했어요');
    }
  }

  void _listenUserProfile(String userId) {
    userProfileSubscription?.cancel();
    userProfileSubscription = _userRepository.watchUserProfile(userId).listen(
      (profile) {
        if (!mounted) {
          return;
        }

        setState(() {
          currentUserProfile = profile;
          currentUserRole = profile.role;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          currentUserProfile = null;
          currentUserRole = 'user';
        });
      },
    );
  }

  void _listenUnreadNotifications(String userId) {
    unreadNotificationsSubscription?.cancel();
    unreadNotificationsSubscription =
        _notificationRepository.watchUnreadCount(userId).listen(
      (count) {
        if (!mounted) {
          return;
        }

        setState(() {
          unreadNotificationsCount = count;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          unreadNotificationsCount = 0;
        });
      },
    );
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
      _showComingSoonMessage('번호 저장은 로그인이 필요해요');
      _openAccountPage();
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

    for (final winningRound in winningRounds) {
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
            color: surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 18,
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

  int get _purchasedNumbersCount {
    return savedNumbers.where((savedNumber) => savedNumber.isPurchased).length;
  }

  String? get _currentUserName {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final profileDisplayName = currentUserProfile?.displayName;

    if (profileDisplayName != null && profileDisplayName.trim().isNotEmpty) {
      return profileDisplayName.trim();
    }

    final displayName = user.displayName;

    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final email = _currentUserEmail;

    if (email != null && email.trim().isNotEmpty) {
      return email.trim();
    }

    return '익명';
  }

  String? get _currentUserEmail {
    return currentUserProfile?.email ?? currentUser?.email;
  }

  String? get _currentUserPhotoUrl {
    final profilePhotoUrl = currentUserProfile?.photoUrl;

    if (profilePhotoUrl != null && profilePhotoUrl.trim().isNotEmpty) {
      return profilePhotoUrl.trim();
    }

    return currentUser?.photoURL;
  }

  bool get _isAdmin {
    return currentUserRole == 'admin';
  }

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
          notificationRepository: _notificationRepository,
        ),
      ),
    );
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

    await _authService.updateDisplayName(displayName);
    await _userRepository.updateDisplayName(
      userId: userId,
      displayName: displayName,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      currentUser = _authService.currentUser;
      currentUserProfile = currentUserProfile?.copyWith(
        displayName: displayName,
      );
    });
  }

  void _openMyNumbersTabFromAccount() {
    Navigator.of(context).maybePop();

    setState(() {
      selectedIndex = 3;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();

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
      await _authService.signInWithGoogle();

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
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

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

  Future<void> _signUpWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showComingSoonMessage('이메일과 비밀번호를 입력해주세요');
      return;
    }

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

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
      await _winningRoundRepository.saveWinningRound(winningRound);

      if (userId != null) {
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
    final checkedAt = DateTime.now();
    final targetSavedNumbers = savedNumbers.where(
      (savedNumber) => savedNumber.round == winningRound.round,
    );

    for (final savedNumber in targetSavedNumbers) {
      final result = _resultChecker.check(
        savedNumber: savedNumber,
        winningRound: winningRound,
      );
      final updatedSavedNumber = savedNumber.copyWith(
        resultStatus: result.status,
        matchCount: result.matchCount,
        isBonusMatched: result.isBonusMatched,
        checkedAt: checkedAt,
        updatedAt: checkedAt,
      );

      await _savedNumberRepository.update(userId, updatedSavedNumber);
    }
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
