import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';

class CommunityPostEditorResult {
  const CommunityPostEditorResult({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

class CommunityPostEditorPage extends StatefulWidget {
  const CommunityPostEditorPage({
    super.key,
    required this.onSubmit,
    this.initialTitle = '',
    this.initialContent = '',
    this.appBarTitle = '글쓰기',
    this.submitLabel = '등록',
    this.savingLabel = '등록 중',
  });

  final Future<void> Function({
    required String title,
    required String content,
  }) onSubmit;
  final String initialTitle;
  final String initialContent;
  final String appBarTitle;
  final String submitLabel;
  final String savingLabel;

  @override
  State<CommunityPostEditorPage> createState() =>
      _CommunityPostEditorPageState();
}

class _CommunityPostEditorPageState extends State<CommunityPostEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _contentController.text = widget.initialContent;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: Text(
          widget.appBarTitle,
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: Text(
              _isSaving ? widget.savingLabel : widget.submitLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _EditorTextField(
                controller: _titleController,
                hintText: '제목',
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              _EditorTextField(
                controller: _contentController,
                hintText: '내용을 입력하세요',
                maxLines: 12,
                minLines: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showMessage('제목을 입력해주세요');
      return;
    }

    if (content.isEmpty) {
      _showMessage('내용을 입력해주세요');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(title: title, content: content);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      _showMessage('${widget.submitLabel}에 실패했어요');
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      CommunityPostEditorResult(title: title, content: content),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _EditorTextField extends StatelessWidget {
  const _EditorTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    this.minLines,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction:
          maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffE6E6E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffE6E6E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mainColor, width: 1.4),
        ),
      ),
    );
  }
}
