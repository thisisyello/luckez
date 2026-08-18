import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.isLoggedIn,
    required this.savedNumbersCount,
    required this.purchasedNumbersCount,
    required this.onGooglePressed,
    required this.onApplePressed,
    this.onSignOutPressed,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
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
        onApplePressed: onApplePressed,
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
    required this.onApplePressed,
    this.onSignOutPressed,
  });

  final bool isLoggedIn;
  final int savedNumbersCount;
  final int purchasedNumbersCount;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final VoidCallback? onSignOutPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
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
            _LoginButton(
              icon: Icons.g_mobiledata,
              label: 'Google로 계속하기',
              onPressed: onGooglePressed,
            ),
            const SizedBox(height: 10),
            _LoginButton(
              icon: Icons.apple,
              label: 'Apple로 계속하기',
              onPressed: onApplePressed,
            ),
          ] else ...[
            _AccountActionButton(
              icon: Icons.logout,
              label: '로그아웃',
              onPressed: onSignOutPressed,
            ),
          ],
        ],
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

class _LoginButton extends StatelessWidget {
  const _LoginButton({
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
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
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

class _AccountActionButton extends StatelessWidget {
  const _AccountActionButton({
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
      height: 52,
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
