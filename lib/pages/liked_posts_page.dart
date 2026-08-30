import 'package:flutter/material.dart';
import 'package:luckez/models/community_liked_post.dart';
import 'package:luckez/pages/community_post_detail_page.dart';
import 'package:luckez/repositories/community_repository.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';

class LikedPostsPage extends StatelessWidget {
  const LikedPostsPage({
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
          '좋아요한 글',
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
          child: StreamBuilder<List<CommunityLikedPost>>(
            stream: communityRepository.watchMyLikedPosts(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LikedPostSkeletonList();
              }

              if (snapshot.hasError) {
                return const _LikedPostStateMessage(
                  icon: Icons.cloud_off_outlined,
                  message: '좋아요한 글을 불러오지 못했어요',
                );
              }

              final likedPosts = snapshot.data ?? const <CommunityLikedPost>[];

              if (likedPosts.isEmpty) {
                return const _LikedPostStateMessage(
                  icon: Icons.favorite_border,
                  message: '아직 좋아요한 글이 없어요',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                itemCount: likedPosts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _LikedPostCard(
                    likedPost: likedPosts[index],
                    onTap: () => _openPost(context, likedPosts[index].postId),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openPost(BuildContext context, String postId) async {
    final post = await communityRepository.fetchPost(postId);

    if (!context.mounted) {
      return;
    }

    if (post == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게시글을 찾을 수 없어요'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

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

class _LikedPostCard extends StatelessWidget {
  const _LikedPostCard({
    required this.likedPost,
    required this.onTap,
  });

  final CommunityLikedPost likedPost;
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
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.favorite,
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
                      likedPost.title.isEmpty ? '제목 없음' : likedPost.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${likedPost.authorName} · ${_formatDate(likedPost.likedAt)} 좋아요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

class _LikedPostStateMessage extends StatelessWidget {
  const _LikedPostStateMessage({
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

class _LikedPostSkeletonList extends StatelessWidget {
  const _LikedPostSkeletonList();

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
                      width: 140,
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
