import 'package:flutter/material.dart';
import 'package:luckez/pages/account_page.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/auth_form_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onSubmit,
    required this.onGooglePressed,
    required this.onSignUpPressed,
  });

  final EmailPasswordSubmitted onSubmit;
  final VoidCallback onGooglePressed;
  final VoidCallback onSignUpPressed;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(
      emailController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('로그인'),
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
                    label: 'Google로 로그인하기',
                    onPressed: widget.onGooglePressed,
                  ),
                  const SizedBox(height: 16),
                  const AuthDivider(label: '이메일 로그인'),
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
                  const SizedBox(height: 14),
                  PrimaryAuthButton(
                    label: '로그인',
                    onPressed: _submit,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AuthSwitchText(
                text: '계정이 없나요?',
                actionText: '회원가입',
                onPressed: widget.onSignUpPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
