import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckez/services/auth_service.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/auth_form_widgets.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({
    super.key,
    required this.onVerify,
    this.onGoogleVerify,
  });

  final Future<void> Function(String email, String password) onVerify;
  final Future<void> Function()? onGoogleVerify;

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  String? requestError;
  bool isVerifying = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (isVerifying) return;
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() {
      emailError =
          widget.onGoogleVerify == null && email.isEmpty ? '이메일을 입력해주세요' : null;
      passwordError = widget.onGoogleVerify == null && password.isEmpty
          ? '비밀번호를 입력해주세요'
          : null;
      requestError = null;
    });
    if (emailError != null || passwordError != null) return;
    setState(() => isVerifying = true);
    try {
      if (widget.onGoogleVerify != null) {
        await widget.onGoogleVerify!();
      } else {
        await widget.onVerify(email, password);
      }
      if (!mounted) return;
      setState(() => isVerifying = false);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('정말 탈퇴하시겠어요?'),
          content: const Text('탈퇴 후에는 삭제된 정보를 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: redColor),
              child: const Text('탈퇴하기'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 탈퇴 기능은 준비 중이에요')),
      );
    } on AuthCancelledException {
      return;
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        requestError = switch (error.code) {
          'user-mismatch' => widget.onGoogleVerify != null
              ? '현재 로그인한 Google 계정을 선택해주세요'
              : '현재 로그인한 계정의 이메일을 입력해주세요',
          'popup-blocked' => '팝업을 허용한 뒤 다시 시도해주세요',
          'password-provider-required' => 'Google 가입 계정은 Google 재인증이 필요해요',
          'wrong-password' ||
          'invalid-credential' ||
          'invalid-email' =>
            '이메일 또는 비밀번호를 확인해주세요',
          'too-many-requests' => '잠시 후 다시 시도해주세요',
          'network-request-failed' => '인터넷 연결을 확인해주세요',
          _ => '본인 확인에 실패했어요. 다시 시도해주세요',
        };
      });
    } catch (_) {
      if (mounted) {
        setState(() => requestError = '본인 확인에 실패했어요. 다시 시도해주세요');
      }
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('회원 탈퇴')),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const Text(
                '탈퇴 전에 확인해주세요',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '삭제되는 정보',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '계정과 프로필, 저장한 번호 및 구매 완료 기록, 개인 활동 목록과 알림이 삭제됩니다.',
                style: TextStyle(color: greyColor, height: 1.6),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1),
              ),
              const Text(
                '작성한 게시글과 댓글',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '작성한 게시글과 댓글은 유지되며, 작성자 이름은 ‘탈퇴한 사용자’로 표시됩니다. 삭제를 원하면 탈퇴 전에 직접 삭제해주세요.',
                style: TextStyle(color: greyColor, height: 1.6),
              ),
              const SizedBox(height: 24),
              const Text(
                '탈퇴 후에는 삭제된 정보를 복구할 수 없습니다.',
                style: TextStyle(color: redColor, height: 1.5),
              ),
              const SizedBox(height: 18),
              if (widget.onGoogleVerify == null) ...[
                AuthTextField(
                  controller: emailController,
                  label: '이메일',
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailError,
                  enabled: !isVerifying,
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 10),
                AuthPasswordField(
                  controller: passwordController,
                  label: '비밀번호',
                  errorText: passwordError,
                  onSubmitted: (_) => _verify(),
                ),
              ],
              if (requestError != null) ...[
                const SizedBox(height: 10),
                Text(requestError!, style: const TextStyle(color: redColor)),
              ],
              const SizedBox(height: 14),
              AppButton.danger(
                label:
                    widget.onGoogleVerify != null ? 'Google로 본인 확인' : '탈퇴',
                icon: widget.onGoogleVerify != null ? Icons.g_mobiledata : null,
                height: 54,
                isLoading: isVerifying,
                onPressed: _verify,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
