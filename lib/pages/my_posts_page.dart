import 'package:flutter/material.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/pages/community_post_detail_page.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({
    super.key,
    required this.userId,
    required this.currentUserName,
    required this.isAdmin,
    required this.communityRepository,
    required this.onLoginRequired,
  });

  final String userId;
  final String? currentUserName;
  final bool isAdmin;
  final CommunityRepository communityRepository;
  final VoidCallback onLoginRequired;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      appBar: AppBar(
        title: const Text(
          '내가 쓴 글',
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
          child: StreamBuilder<List<CommunityPost>>(
            stream: communityRepository.watchMyPosts(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _MyPostSkeletonList();
              }

              if (snapshot.hasError) {
                return const _MyPostStateMessage(
                  icon: Icons.cloud_off_outlined,
                  message: '내가 쓴 글을 불러오지 못했어요',
                );
              }

              final posts = snapshot.data ?? const <CommunityPost>[];

              if (posts.isEmpty) {
                return const _MyPostStateMessage(
                  icon: Icons.article_outlined,
                  message: '아직 작성한 글이 없어요',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _MyPostCard(
                    post: posts[index],
                    onTap: () => _openPost(context, posts[index]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openPost(BuildContext context, CommunityPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailPage(
          post: post,
          currentUserId: userId,
          currentUserName: currentUserName,
          isAdmin: isAdmin,
          onLoginRequired: onLoginRequired,
          communityRepository: communityRepository,
        ),
      ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  const _MyPostCard({
    required this.post,
    required this.onTap,
  });

  final CommunityPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: whiteColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AppCard(
          showShadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: mainColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title.isEmpty ? '제목 없음' : post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff555555),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatDate(post.createdAt),
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.favorite_border,
                          color: greyColor,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${post.likeCount}',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.mode_comment_outlined,
                          color: greyColor,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: greyColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _MyPostStateMessage extends StatelessWidget {
  const _MyPostStateMessage({
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
          Icon(icon, color: greyColor, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPostSkeletonList extends StatelessWidget {
  const _MyPostSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) {
        return AppCard(
          showShadow: false,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffEEEEEE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
