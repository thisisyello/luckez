import 'package:flutter/material.dart';
import 'package:luckez/pages/account_page.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/app_card.dart';

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
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '로그인',
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
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _AuthFormCard(
                children: [
                  _SocialAuthButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google로 로그인하기',
                    onPressed: widget.onGooglePressed,
                  ),
                  const SizedBox(height: 16),
                  const _AuthDivider(label: '이메일 로그인'),
                  const SizedBox(height: 16),
                  _AccountTextField(
                    controller: emailController,
                    label: '이메일',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 10),
                  _AccountTextField(
                    controller: passwordController,
                    label: '비밀번호',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAuthButton(
                    label: '로그인',
                    onPressed: _submit,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AuthSwitchText(
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

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _AccountTextField extends StatelessWidget {
  const _AccountTextField({
    required this.controller,
    required this.label,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: greyColor,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xffF7F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mainColor),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: label,
      onPressed: onPressed,
      height: 54,
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton.neutral(
      label: label,
      icon: icon,
      onPressed: onPressed,
      height: 56,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xffE6E6E8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: greyColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xffE6E6E8))),
      ],
    );
  }
}

class _AuthSwitchText extends StatelessWidget {
  const _AuthSwitchText({
    required this.text,
    required this.actionText,
    required this.onPressed,
  });

  final String text;
  final String actionText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: greyColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionText,
            style: const TextStyle(
              color: mainColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
