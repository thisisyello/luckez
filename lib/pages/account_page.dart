import 'package:flutter/material.dart';
import 'package:luckez/pages/login_page.dart';
import 'package:luckez/pages/sign_up_page.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';

typedef EmailPasswordSubmitted = void Function(String email, String password);

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onSignOutPressed,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final VoidCallback? onSignOutPressed;

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
        onGooglePressed: onGooglePressed,
        onEmailLoginPressed: onEmailLoginPressed,
        onEmailSignUpPressed: onEmailSignUpPressed,
        onSignOutPressed: onSignOutPressed,
      ),
    );
  }
}

class AccountPageContent extends StatelessWidget {
  const AccountPageContent({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.onGooglePressed,
    required this.onEmailLoginPressed,
    required this.onEmailSignUpPressed,
    this.onSignOutPressed,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailLoginPressed;
  final EmailPasswordSubmitted onEmailSignUpPressed;
  final VoidCallback? onSignOutPressed;

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
              _PrimaryAccountButton(
                icon: Icons.login,
                label: '로그인',
                onPressed: () => _openLoginPage(context),
              ),
              const SizedBox(height: 10),
              _SecondaryAccountButton(
                icon: Icons.person_add_alt_1_outlined,
                label: '회원가입',
                onPressed: () => _openSignUpPage(context),
              ),
            ] else ...[
              _SecondaryAccountButton(
                icon: Icons.logout,
                label: '로그아웃',
                onPressed: onSignOutPressed,
              ),
            ],
          ],
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
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withOpacity(0.12),
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

class _PrimaryAccountButton extends StatelessWidget {
  const _PrimaryAccountButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          foregroundColor: whiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SecondaryAccountButton extends StatelessWidget {
  const _SecondaryAccountButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: blackColor,
          backgroundColor: whiteColor,
          side: const BorderSide(color: Color(0xffE6E6E8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
