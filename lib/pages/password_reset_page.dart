import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/auth_form_widgets.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({
    super.key,
    this.initialEmail = '',
    required this.onSubmit,
  });

  final String initialEmail;
  final Future<void> Function(String email) onSubmit;

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  late final TextEditingController emailController;
  String? emailError;
  String? requestError;
  bool isSubmitting = false;
  bool isSent = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isSubmitting || isSent) return;

    final email = emailController.text.trim();
    final error = email.isEmpty
        ? '이메일을 입력해주세요'
        : !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
            ? '올바른 이메일 주소를 입력해주세요'
            : null;
    setState(() {
      emailError = error;
      requestError = null;
    });
    if (error != null) return;

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(email);
      if (mounted) setState(() => isSent = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        switch (error.code) {
          case 'user-not-found':
            isSent = true;
            break;
          case 'invalid-email':
            emailError = '올바른 이메일 주소를 입력해주세요';
            break;
          case 'too-many-requests':
            requestError = '요청이 많아요. 잠시 후 다시 시도해주세요';
            break;
          case 'network-request-failed':
            requestError = '인터넷 연결을 확인한 뒤 다시 시도해주세요';
            break;
          default:
            requestError = '메일을 보내지 못했어요. 다시 시도해주세요';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          requestError = '메일을 보내지 못했어요. 다시 시도해주세요';
        });
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              AuthFormCard(
                children: [
                  AuthTextField(
                    controller: emailController,
                    label: '이메일',
                    keyboardType: TextInputType.emailAddress,
                    errorText: emailError,
                    enabled: !isSubmitting && !isSent,
                    onChanged: (_) => setState(() {
                      emailError = null;
                      requestError = null;
                    }),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  if (isSent) ...[
                    const Text(
                      '비밀번호 재설정 메일을 보냈어요. 이메일을 확인해주세요.',
                      style: TextStyle(color: textPrimaryColor, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    AppButton.primary(
                      label: '로그인으로 돌아가기',
                      height: 54,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ] else ...[
                    if (requestError != null) ...[
                      Text(requestError!,
                          style: const TextStyle(color: redColor)),
                      const SizedBox(height: 14),
                    ],
                    AppButton.primary(
                      label: '재설정 메일 보내기',
                      height: 54,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Google로 가입한 경우 Google 로그인을 이용해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: greyColor, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
