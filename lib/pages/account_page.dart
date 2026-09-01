import 'package:flutter/material.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/pages/liked_posts_page.dart';
import 'package:luckez/pages/my_comments_page.dart';
import 'package:luckez/pages/my_posts_page.dart';
import 'package:luckez/pages/profile_page.dart';
import 'package:luckez/pages/purchased_numbers_page.dart';
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
typedef DisplayNameSubmitted = Future<void> Function(String displayName);

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.savedNumbers,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.currentUserPhotoUrl,
    required this.isAdmin,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onDisplayNameSubmit,
    this.onSavedNumbersPressed,
    this.onSignOutPressed,
    this.onWinningRoundSubmit,
    this.initialWinningRound,
    this.isWinningRoundRegistered,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final List<SavedLottoNumber> savedNumbers;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserEmail;
  final String? currentUserPhotoUrl;
  final bool isAdmin;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final DisplayNameSubmitted? onDisplayNameSubmit;
  final VoidCallback? onSavedNumbersPressed;
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
        savedNumbers: savedNumbers,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserEmail: currentUserEmail,
        currentUserPhotoUrl: currentUserPhotoUrl,
        isAdmin: isAdmin,
        onGooglePressed: onGooglePressed,
        onEmailLoginPressed: onEmailLoginPressed,
        onEmailSignUpPressed: onEmailSignUpPressed,
        onDisplayNameSubmit: onDisplayNameSubmit,
        onSavedNumbersPressed: onSavedNumbersPressed,
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
    required this.savedNumbers,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.currentUserPhotoUrl,
    required this.isAdmin,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onDisplayNameSubmit,
    this.onSavedNumbersPressed,
    this.onSignOutPressed,
    this.onWinningRoundSubmit,
    this.initialWinningRound,
    this.isWinningRoundRegistered,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final List<SavedLottoNumber> savedNumbers;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserEmail;
  final String? currentUserPhotoUrl;
  final bool isAdmin;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final DisplayNameSubmitted? onDisplayNameSubmit;
  final VoidCallback? onSavedNumbersPressed;
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
            _AccountProfileCard(
              isLoggedIn: isLoggedIn,
              displayName: currentUserName,
              email: currentUserEmail,
              photoUrl: currentUserPhotoUrl,
              onTap: isLoggedIn ? () => _openProfilePage(context) : null,
            ),
            const SizedBox(height: 18),
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
              _AccountSectionTitle(title: '나의 번호'),
              _AccountActivityMenu(
                items: [
                  _AccountActivityMenuItemData(
                    icon: Icons.confirmation_number_outlined,
                    title: '저장한 번호',
                    trailingText: '$savedNumbersCount개',
                    onTap: () => _openSavedNumbers(context),
                  ),
                  _AccountActivityMenuItemData(
                    icon: Icons.shopping_bag_outlined,
                    title: '구매한 번호',
                    trailingText: '$purchasedNumbersCount개',
                    onTap: () => _openPurchasedNumbersPage(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AccountSectionTitle(title: '나의 활동'),
              _AccountActivityMenu(
                items: [
                  _AccountActivityMenuItemData(
                    icon: Icons.article_outlined,
                    title: '내가 쓴 글',
                    onTap: () => _openMyPostsPage(context),
                  ),
                  _AccountActivityMenuItemData(
                    icon: Icons.mode_comment_outlined,
                    title: '내 댓글',
                    onTap: () => _openMyCommentsPage(context),
                  ),
                  _AccountActivityMenuItemData(
                    icon: Icons.favorite_border,
                    title: '내가 좋아요한 글',
                    onTap: () => _openLikedPostsPage(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  onPressed: onSignOutPressed,
                  icon: const Icon(Icons.logout, size: 17),
                  label: const Text('로그아웃'),
                  style: TextButton.styleFrom(
                    foregroundColor: greyColor,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openProfilePage(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    final onSubmit = onDisplayNameSubmit;

    if (onSubmit == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          userId: userId,
          displayName: currentUserName,
          email: currentUserEmail,
          photoUrl: currentUserPhotoUrl,
          role: isAdmin ? 'admin' : 'user',
          onDisplayNameSubmit: onSubmit,
        ),
      ),
    );
  }

  void _openSavedNumbers(BuildContext context) {
    onSavedNumbersPressed?.call();
  }

  void _openPurchasedNumbersPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchasedNumbersPage(savedNumbers: savedNumbers),
      ),
    );
  }

  void _openMyPostsPage(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyPostsPage(
          userId: userId,
          currentUserName: currentUserName,
          isAdmin: isAdmin,
          communityRepository: _communityRepository,
          onLoginRequired: () {},
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

class _AccountProfileCard extends StatelessWidget {
  const _AccountProfileCard({
    required this.isLoggedIn,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.onTap,
  });

  final bool isLoggedIn;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = isLoggedIn
        ? _displayText(displayName) ?? _displayText(email) ?? '익명'
        : '로그인이 필요해요';
    final subtitle = isLoggedIn
        ? _displayText(email) ?? '내 정보를 확인할 수 있어요'
        : '번호 저장과 내 번호 확인은 로그인 후 사용할 수 있어요';

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AppCard(
          showShadow: false,
          child: Row(
            children: [
              _AccountProfileAvatar(photoUrl: isLoggedIn ? photoUrl : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoggedIn) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: greyColor,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _displayText(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _AccountProfileAvatar extends StatelessWidget {
  const _AccountProfileAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _FallbackAccountAvatar(),
        ),
      );
    }

    return const _FallbackAccountAvatar();
  }
}

class _FallbackAccountAvatar extends StatelessWidget {
  const _FallbackAccountAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mainColor.withValues(alpha: 0.12),
      ),
      child: const Icon(
        Icons.account_circle_outlined,
        color: mainColor,
        size: 28,
      ),
    );
  }
}

class _AccountSectionTitle extends StatelessWidget {
  const _AccountSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xffE8E8E8))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: greyColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xffE8E8E8))),
        ],
      ),
    );
  }
}

class _AccountActivityMenuItemData {
  const _AccountActivityMenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
}

class _AccountActivityMenu extends StatelessWidget {
  const _AccountActivityMenu({required this.items});

  final List<_AccountActivityMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      showShadow: false,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _AccountActivityMenuItem(item: items[index]),
            if (index != items.length - 1)
              const Divider(
                height: 1,
                indent: 56,
                color: Color(0xffEEEEEE),
              ),
          ],
        ],
      ),
    );
  }
}

class _AccountActivityMenuItem extends StatelessWidget {
  const _AccountActivityMenuItem({required this.item});

  final _AccountActivityMenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: textPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (item.trailingText != null) ...[
              Text(
                item.trailingText!,
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: greyColor,
              size: 20,
            ),
          ],
        ),
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
