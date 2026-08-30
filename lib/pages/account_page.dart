import 'package:flutter/material.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/pages/liked_posts_page.dart';
import 'package:luckez/pages/my_comments_page.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/pages/login_page.dart';
import 'package:luckez/pages/sign_up_page.dart';
import 'package:luckez/pages/winning_round_admin_page.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/app_card.dart';

typedef EmailPasswordSubmitted = void Function(String email, String password);
typedef WinningRoundSubmitted = Future<void> Function(
  LottoWinningRound winningRound,
);
typedef WinningRoundRegisteredCheck = bool Function(int round);

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onSignOutPressed,
    this.onWinningRoundSubmit,
    this.initialWinningRound,
    this.isWinningRoundRegistered,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final String? currentUserId;
  final String? currentUserName;
  final bool isAdmin;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final VoidCallback? onSignOutPressed;
  final WinningRoundSubmitted? onWinningRoundSubmit;
  final int? initialWinningRound;
  final WinningRoundRegisteredCheck? isWinningRoundRegistered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '계정',
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
      body: AccountPageContent(
        isLoggedIn: isLoggedIn,
        savedNumbersCount: savedNumbersCount,
        purchasedNumbersCount: purchasedNumbersCount,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        isAdmin: isAdmin,
        onGooglePressed: onGooglePressed,
        onEmailLoginPressed: onEmailLoginPressed,
        onEmailSignUpPressed: onEmailSignUpPressed,
        onSignOutPressed: onSignOutPressed,
        onWinningRoundSubmit: onWinningRoundSubmit,
        initialWinningRound: initialWinningRound,
        isWinningRoundRegistered: isWinningRoundRegistered,
      ),
    );
  }
}

class AccountPageContent extends StatelessWidget {
  static final _communityRepository = CommunityRepository();

  const AccountPageContent({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onSignOutPressed,
    this.onWinningRoundSubmit,
    this.initialWinningRound,
    this.isWinningRoundRegistered,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final String? currentUserId;
  final String? currentUserName;
  final bool isAdmin;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final VoidCallback? onSignOutPressed;
  final WinningRoundSubmitted? onWinningRoundSubmit;
  final int? initialWinningRound;
  final WinningRoundRegisteredCheck? isWinningRoundRegistered;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: PageContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _AccountStatusCard(
              isLoggedIn: isLoggedIn,
              savedNumbersCount: savedNumbersCount,
              purchasedNumbersCount: purchasedNumbersCount,
            ),
            const SizedBox(height: 14),
            if (!isLoggedIn) ...[
              AppButton.primary(
                icon: Icons.login,
                label: '로그인',
                onPressed: () => _openLoginPage(context),
                height: 54,
              ),
              const SizedBox(height: 10),
              AppButton.neutral(
                icon: Icons.person_add_alt_1_outlined,
                label: '회원가입',
                onPressed: () => _openSignUpPage(context),
                height: 54,
              ),
            ] else ...[
              if (onWinningRoundSubmit != null &&
                  initialWinningRound != null) ...[
                _TemporaryAdminButton(
                  onPressed: () => _openWinningRoundAdminPage(context),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppButton.neutral(
                      icon: Icons.favorite_border,
                      label: '좋아요한 글',
                      onPressed: () => _openLikedPostsPage(context),
                      height: 54,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.neutral(
                      icon: Icons.mode_comment_outlined,
                      label: '내 댓글',
                      onPressed: () => _openMyCommentsPage(context),
                      height: 54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppButton.neutral(
                icon: Icons.logout,
                label: '로그아웃',
                onPressed: onSignOutPressed,
                height: 54,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openLikedPostsPage(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LikedPostsPage(
          userId: userId,
          currentUserName: currentUserName,
          isAdmin: isAdmin,
          communityRepository: _communityRepository,
          onLoginRequired: () {},
        ),
      ),
    );
  }

  void _openMyCommentsPage(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyCommentsPage(
          userId: userId,
          currentUserName: currentUserName,
          isAdmin: isAdmin,
          communityRepository: _communityRepository,
          onLoginRequired: () {},
        ),
      ),
    );
  }

  void _openLoginPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onSubmit: onEmailLoginPressed,
          onGooglePressed: onGooglePressed,
          onSignUpPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SignUpPage(
                  onGooglePressed: onGooglePressed,
                  onEmailSubmit: onEmailSignUpPressed,
                  onLoginPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          onSubmit: onEmailLoginPressed,
                          onGooglePressed: onGooglePressed,
                          onSignUpPressed: () => _openSignUpPage(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openWinningRoundAdminPage(BuildContext context) {
    final onSubmit = onWinningRoundSubmit;
    final initialRound = initialWinningRound;
    final isRegistered = isWinningRoundRegistered;

    if (onSubmit == null || initialRound == null || isRegistered == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WinningRoundAdminPage(
          initialRound: initialRound,
          isRoundRegistered: isRegistered,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  void _openSignUpPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpPage(
          onGooglePressed: onGooglePressed,
          onEmailSubmit: onEmailSignUpPressed,
          onLoginPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  onSubmit: onEmailLoginPressed,
                  onGooglePressed: onGooglePressed,
                  onSignUpPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => SignUpPage(
                          onGooglePressed: onGooglePressed,
                          onEmailSubmit: onEmailSignUpPressed,
                          onLoginPressed: () => _openLoginPage(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.person_outline,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? '로그인됨' : '로그인이 필요해요',
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn
                          ? '저장번호와 알림을 사용할 수 있어요'
                          : '번호 저장과 내 번호 확인은 로그인 후 사용할 수 있어요',
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AccountStatItem(
                  label: '저장한 번호',
                  value: '$savedNumbersCount개',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AccountStatItem(
                  label: '구매 완료',
                  value: '$purchasedNumbersCount개',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountStatItem extends StatelessWidget {
  const _AccountStatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF7F7F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: greyColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: blackColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemporaryAdminButton extends StatelessWidget {
  const _TemporaryAdminButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('당첨번호 등록'),
        style: TextButton.styleFrom(
          foregroundColor: greyColor,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
