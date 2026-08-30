import 'package:flutter/material.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/models/community_report.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/app_card.dart';

class CommunityPostDetailPage extends StatefulWidget {
  const CommunityPostDetailPage({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onLoginRequired,
    required this.communityRepository,
  });

  final CommunityPost post;
  final String? currentUserId;
  final String? currentUserName;
  final bool isAdmin;
  final VoidCallback onLoginRequired;
  final CommunityRepository communityRepository;

  @override
  State<CommunityPostDetailPage> createState() =>
      _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends State<CommunityPostDetailPage> {
  final _commentController = TextEditingController();
  late int _likeCount;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
  }

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
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _openReportDialog(
              targetType: CommunityReportTargetType.post,
              targetId: widget.post.id,
              postId: widget.post.id,
            ),
          ),
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
                isLikedStream: widget.communityRepository.watchPostLike(
                  postId: widget.post.id,
                  userId: widget.currentUserId,
                ),
                likeCount: _likeCount,
                onToggleLike: _toggleLike,
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<CommunityComment>>(
                stream: widget.communityRepository.watchComments(widget.post.id),
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
                              onReport: () => _openReportDialog(
                                targetType: CommunityReportTargetType.comment,
                                targetId: comment.id,
                                postId: widget.post.id,
                              ),
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

  Future<void> _toggleLike(bool isLiked) async {
    final previousCount = _likeCount;

    setState(() {
      _likeCount = (_likeCount + (isLiked ? -1 : 1)).clamp(0, 1 << 31);
    });

    try {
      final userId = widget.currentUserId;

      if (userId == null) {
        widget.onLoginRequired();
        return;
      }

      await widget.communityRepository.togglePostLike(
        postId: widget.post.id,
        userId: userId,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _likeCount = previousCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('좋아요 처리에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  bool get _canDeletePost {
    return widget.isAdmin || widget.currentUserId == widget.post.authorId;
  }

  bool _canDeleteComment(CommunityComment comment) {
    return widget.isAdmin || widget.currentUserId == comment.authorId;
  }

  Future<void> _openReportDialog({
    required String targetType,
    required String targetId,
    required String postId,
  }) async {
    if (widget.currentUserId == null) {
      widget.onLoginRequired();
      return;
    }

    final descriptionController = TextEditingController();
    var selectedReason = CommunityReportReason.spam;

    final shouldReport = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('신고할까요?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CommunityReportReason>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(
                      labelText: '신고 사유',
                    ),
                    items: CommunityReportReason.values
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason.label),
                          ),
                        )
                        .toList(),
                    onChanged: (reason) {
                      if (reason == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedReason = reason;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: '추가 설명',
                      hintText: '선택 입력',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('신고'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldReport != true || !mounted) {
      descriptionController.dispose();
      return;
    }

    try {
      await widget.communityRepository.createReport(
        targetType: targetType,
        targetId: targetId,
        postId: postId,
        reporterId: widget.currentUserId!,
        reason: selectedReason.value,
        description: descriptionController.text,
      );
    } catch (_) {
      descriptionController.dispose();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신고 등록에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    descriptionController.dispose();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('신고가 접수됐어요'),
        duration: Duration(seconds: 1),
      ),
    );
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
      await widget.communityRepository.createComment(
        postId: widget.post.id,
        content: content,
        authorId: widget.currentUserId!,
        authorName: widget.currentUserName ?? '익명',
      );
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
      await widget.communityRepository.deleteComment(
        postId: widget.post.id,
        commentId: comment.id,
      );
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
      await widget.communityRepository.deletePost(widget.post.id);
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
    required this.isLikedStream,
    required this.likeCount,
    required this.onToggleLike,
  });

  final CommunityPost post;
  final String formattedDate;
  final Stream<bool> isLikedStream;
  final int likeCount;
  final Future<void> Function(bool isLiked) onToggleLike;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      showShadow: false,
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
          const SizedBox(height: 18),
          StreamBuilder<bool>(
            stream: isLikedStream,
            initialData: false,
            builder: (context, snapshot) {
              final isLiked = snapshot.data ?? false;

              return Align(
                alignment: Alignment.centerLeft,
                child: _PostLikeButton(
                  isLiked: isLiked,
                  likeCount: likeCount,
                  onPressed: () => onToggleLike(isLiked),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostLikeButton extends StatelessWidget {
  const _PostLikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.onPressed,
  });

  final bool isLiked;
  final int likeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        size: 18,
      ),
      label: Text('좋아요 $likeCount'),
      style: OutlinedButton.styleFrom(
        foregroundColor: isLiked ? mainColor : greyColor,
        side: BorderSide(
          color: isLiked ? mainColor : borderColor,
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
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
    return AppCard(
      padding: const EdgeInsets.all(18),
      showShadow: false,
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
      return AppButton.secondary(
        label: '로그인하고 댓글 쓰기',
        onPressed: onLoginRequired,
        height: 46,
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
          child: AppButton.primary(
            label: '등록',
            onPressed: canSubmit ? onSubmit : null,
            isLoading: isSubmitting,
            height: 46,
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
    required this.onReport,
  });

  final CommunityComment comment;
  final bool canDelete;
  final String formattedDate;
  final VoidCallback onDelete;
  final VoidCallback onReport;

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
              const SizedBox(width: 2),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: greyColor,
                ),
                onPressed: onReport,
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
    return AppCard(
      padding: const EdgeInsets.all(18),
      showShadow: false,
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
