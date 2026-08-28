import 'package:flutter/material.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/pages/community_post_detail_page.dart';
import 'package:luckez/pages/community_post_editor_page.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onLoginRequired,
  });

  static final _communityRepository = CommunityRepository();

  final String? currentUserId;
  final String? currentUserName;
  final bool isAdmin;
  final VoidCallback onLoginRequired;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xffF7F7F8),
      child: PageContentWidth(
        child: Stack(
          children: [
            StreamBuilder<List<CommunityPost>>(
              stream: _communityRepository.watchPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _CommunitySkeletonList();
                }

                if (snapshot.hasError) {
                  return const _CommunityStateMessage(
                    icon: Icons.cloud_off_outlined,
                    message: '게시글을 불러오지 못했어요',
                  );
                }

                final posts = snapshot.data ?? const <CommunityPost>[];

                if (posts.isEmpty) {
                  return const _CommunityStateMessage(
                    icon: Icons.forum_outlined,
                    message: '아직 작성된 글이 없어요',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _CommunityPostCard(
                      post: posts[index],
                      currentUserId: currentUserId,
                      currentUserName: currentUserName,
                      isAdmin: isAdmin,
                      onLoginRequired: onLoginRequired,
                      onDelete: _communityRepository.deletePost,
                      commentsStream:
                          _communityRepository.watchComments(posts[index].id),
                      onCreateComment: ({required content}) {
                        final userId = currentUserId;

                        if (userId == null) {
                          onLoginRequired();
                          return Future.value();
                        }

                        return _communityRepository.createComment(
                          postId: posts[index].id,
                          content: content,
                          authorId: userId,
                          authorName: currentUserName ?? '익명',
                        );
                      },
                      onDeleteComment: (commentId) {
                        return _communityRepository.deleteComment(
                          postId: posts[index].id,
                          commentId: commentId,
                        );
                      },
                      onCreateReport: ({
                        required targetType,
                        required targetId,
                        required postId,
                        required reason,
                        description,
                      }) {
                        final userId = currentUserId;

                        if (userId == null) {
                          onLoginRequired();
                          return Future.value();
                        }

                        return _communityRepository.createReport(
                          targetType: targetType,
                          targetId: targetId,
                          postId: postId,
                          reporterId: userId,
                          reason: reason,
                          description: description,
                        );
                      },
                    );
                  },
                );
              },
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _openEditor(context),
                backgroundColor: mainColor,
                foregroundColor: whiteColor,
                elevation: 0,
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  '글쓰기',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      onLoginRequired();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostEditorPage(
          onSubmit: ({required title, required content}) {
            return _communityRepository.createPost(
              title: title,
              content: content,
              authorId: userId,
              authorName: currentUserName ?? '익명',
            );
          },
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.currentUserId,
    required this.currentUserName,
    required this.isAdmin,
    required this.onLoginRequired,
    required this.onDelete,
    required this.commentsStream,
    required this.onCreateComment,
    required this.onDeleteComment,
    required this.onCreateReport,
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
  final Future<void> Function({
    required String targetType,
    required String targetId,
    required String postId,
    required String reason,
    String? description,
  }) onCreateReport;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: whiteColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CommunityPostDetailPage(
                post: post,
                currentUserId: currentUserId,
                currentUserName: currentUserName,
                isAdmin: isAdmin,
                onLoginRequired: onLoginRequired,
                onDelete: onDelete,
                commentsStream: commentsStream,
                onCreateComment: onCreateComment,
                onDeleteComment: onDeleteComment,
                onCreateReport: onCreateReport,
              ),
            ),
          );
        },
        child: AppCard(
          showShadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title.isEmpty ? '제목 없음' : post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff555555),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${post.authorName} · ${_formatDate(post.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.mode_comment_outlined,
                    size: 15,
                    color: greyColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(
                      color: greyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

class _CommunityStateMessage extends StatelessWidget {
  const _CommunityStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: greyColor,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunitySkeletonList extends StatelessWidget {
  const _CommunitySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _CommunitySkeletonCard(),
    );
  }
}

class _CommunitySkeletonCard extends StatelessWidget {
  const _CommunitySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      showShadow: false,
      child: SizedBox(
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBar(width: 180, height: 16),
            SizedBox(height: 12),
            _SkeletonBar(width: double.infinity, height: 12),
            SizedBox(height: 8),
            _SkeletonBar(width: 220, height: 12),
            Spacer(),
            _SkeletonBar(width: 140, height: 11),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
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
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
