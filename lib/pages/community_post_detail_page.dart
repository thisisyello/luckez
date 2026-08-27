import 'package:flutter/material.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';

class CommunityPostDetailPage extends StatefulWidget {
  const CommunityPostDetailPage({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onLoginRequired,
    required this.onDelete,
    required this.commentsStream,
    required this.onCreateComment,
    required this.onDeleteComment,
  });

  final CommunityPost post;
  final String? currentUserId;
  final String? currentUserName;
  final bool isAdmin;
  final VoidCallback onLoginRequired;
  final Future<void> Function(String postId) onDelete;
  final Stream<List<CommunityComment>> commentsStream;
  final Future<void> Function({required String content}) onCreateComment;
  final Future<void> Function(String commentId) onDeleteComment;

  @override
  State<CommunityPostDetailPage> createState() =>
      _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends State<CommunityPostDetailPage> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '게시글',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        actions: [
          if (_canDeletePost)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _PostContentCard(
                post: widget.post,
                formattedDate: _formatFullDate(widget.post.createdAt),
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<CommunityComment>>(
                stream: widget.commentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _CommentSectionSkeleton();
                  }

                  if (snapshot.hasError) {
                    return _CommentSectionShell(
                      count: widget.post.commentCount,
                      child: const _CommentStateMessage(
                        icon: Icons.cloud_off_outlined,
                        message: '댓글을 불러오지 못했어요',
                      ),
                    );
                  }

                  final comments = snapshot.data ?? const <CommunityComment>[];

                  return _CommentSectionShell(
                    count: comments.length,
                    child: Column(
                      children: [
                        _CommentInput(
                          controller: _commentController,
                          isLoggedIn: widget.currentUserId != null,
                          isSubmitting: _isSubmittingComment,
                          onLoginRequired: widget.onLoginRequired,
                          onChanged: (_) => setState(() {}),
                          onSubmit: _submitComment,
                        ),
                        const SizedBox(height: 14),
                        if (comments.isEmpty)
                          const _CommentStateMessage(
                            icon: Icons.mode_comment_outlined,
                            message: '아직 댓글이 없어요',
                          )
                        else
                          ...comments.map(
                            (comment) => _CommentTile(
                              comment: comment,
                              canDelete: _canDeleteComment(comment),
                              formattedDate: _formatRelativeDate(
                                comment.createdAt,
                              ),
                              onDelete: () => _confirmDeleteComment(comment),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canDeletePost {
    return widget.isAdmin || widget.currentUserId == widget.post.authorId;
  }

  bool _canDeleteComment(CommunityComment comment) {
    return widget.isAdmin || widget.currentUserId == comment.authorId;
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();

    if (widget.currentUserId == null) {
      widget.onLoginRequired();
      return;
    }

    if (content.isEmpty || _isSubmittingComment) {
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await widget.onCreateComment(content: content);
      _commentController.clear();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('댓글 등록에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteComment(CommunityComment comment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('댓글을 삭제할까요?'),
          content: const Text('삭제한 댓글은 목록에서 보이지 않아요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await widget.onDeleteComment(comment.id);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('댓글 삭제에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시글을 삭제할까요?'),
          content: const Text('삭제한 글은 목록에서 보이지 않아요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await widget.onDelete(widget.post.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게시글 삭제에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('게시글을 삭제했어요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    }

    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _PostContentCard extends StatelessWidget {
  const _PostContentCard({
    required this.post,
    required this.formattedDate,
  });

  final CommunityPost post;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title.isEmpty ? '제목 없음' : post.title,
            style: const TextStyle(
              color: blackColor,
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  post.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          const SizedBox(height: 18),
          Text(
            post.content,
            style: const TextStyle(
              color: Color(0xff333333),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSectionShell extends StatelessWidget {
  const _CommentSectionShell({
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mode_comment_outlined,
                color: greyColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '댓글 $count개',
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.isLoggedIn,
    required this.isSubmitting,
    required this.onLoginRequired,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isLoggedIn;
  final bool isSubmitting;
  final VoidCallback onLoginRequired;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return OutlinedButton(
        onPressed: onLoginRequired,
        style: OutlinedButton.styleFrom(
          foregroundColor: mainColor,
          side: const BorderSide(color: Color(0xffF0B5C0)),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '로그인하고 댓글 쓰기',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      );
    }

    final canSubmit = controller.text.trim().isNotEmpty && !isSubmitting;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '댓글을 입력하세요',
              hintStyle: const TextStyle(
                color: greyColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: const Color(0xffF7F7F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: whiteColor,
              disabledBackgroundColor: const Color(0xffE5E5E5),
              disabledForegroundColor: greyColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: whiteColor,
                    ),
                  )
                : const Text(
                    '등록',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.formattedDate,
    required this.onDelete,
  });

  final CommunityComment comment;
  final bool canDelete;
  final String formattedDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xffF1F1F1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 2),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    size: 17,
                    color: greyColor,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: const TextStyle(
              color: Color(0xff333333),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentStateMessage extends StatelessWidget {
  const _CommentStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: greyColor, size: 24),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: greyColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentSectionSkeleton extends StatelessWidget {
  const _CommentSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SkeletonLine(width: 96, height: 16),
          SizedBox(height: 16),
          _SkeletonLine(width: double.infinity, height: 14),
          SizedBox(height: 8),
          _SkeletonLine(width: 180, height: 14),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
