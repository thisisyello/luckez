import 'package:flutter/material.dart';
import 'package:luckez/pages/account_page.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/auth_form_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.onGooglePressed,
    required this.onEmailSubmit,
    required this.onLoginPressed,
  });

  final VoidCallback onGooglePressed;
  final EmailPasswordSubmitted onEmailSubmit;
  final VoidCallback onLoginPressed;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;

    if (password != passwordConfirm) {
      setState(() {
        errorText = '비밀번호가 일치하지 않습니다';
      });
      return;
    }

    setState(() {
      errorText = null;
    });
    widget.onEmailSubmit(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              AuthFormCard(
                children: [
                  SocialAuthButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google로 가입하기',
                    onPressed: widget.onGooglePressed,
                  ),
                  const SizedBox(height: 16),
                  const AuthDivider(label: '이메일 가입'),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: emailController,
                    label: '이메일',
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 10),
                  AuthPasswordField(
                    controller: passwordController,
                    label: '비밀번호',
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 10),
                  AuthPasswordField(
                    controller: passwordConfirmController,
                    label: '비밀번호 확인',
                    onSubmitted: (_) => _submit(),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        color: redColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  PrimaryAuthButton(
                    label: '이메일로 가입하기',
                    onPressed: _submit,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AuthSwitchText(
                text: '이미 계정이 있나요?',
                actionText: '로그인',
                onPressed: widget.onLoginPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
