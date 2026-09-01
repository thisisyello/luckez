import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';

typedef DisplayNameSubmitted = Future<void> Function(String displayName);

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.onDisplayNameSubmit,
  });

  final String userId;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String role;
  final DisplayNameSubmitted onDisplayNameSubmit;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? displayName;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    displayName = widget.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final name =
        _displayText(displayName) ?? _displayText(widget.email) ?? '익명';
    final emailText = _displayText(widget.email) ?? '이메일 정보 없음';

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '내 정보',
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
              AppCard(
                showShadow: false,
                child: Column(
                  children: [
                    _ProfileAvatar(photoUrl: widget.photoUrl, size: 72),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      emailText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed:
                          isSubmitting ? null : () => _openNameEditDialog(name),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('이름 수정'),
                      style: TextButton.styleFrom(
                        foregroundColor: mainColor,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: EdgeInsets.zero,
                showShadow: false,
                child: Column(
                  children: [
                    _ProfileInfoRow(
                      label: '회원 등급',
                      value: widget.role == 'admin' ? '관리자' : '일반 회원',
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ProfileInfoRow(
                      label: '사용자 ID',
                      value: widget.userId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNameEditDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이름 수정'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '이름',
              hintText: '표시할 이름을 입력하세요',
            ),
            onSubmitted: (value) => Navigator.pop(context, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final trimmedName = updatedName?.trim();

    if (trimmedName == null ||
        trimmedName.isEmpty ||
        trimmedName == displayName) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await widget.onDisplayNameSubmit(trimmedName);

      if (!mounted) {
        return;
      }

      setState(() {
        displayName = trimmedName;
      });

      Navigator.of(context).pop(trimmedName);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름 수정에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String? _displayText(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.size,
  });

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(size: size),
        ),
      );
    }

    return _FallbackAvatar(size: size);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mainColor.withValues(alpha: 0.12),
      ),
      child: Icon(
        Icons.account_circle_outlined,
        color: mainColor,
        size: size * 0.56,
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: greyColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: blackColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
