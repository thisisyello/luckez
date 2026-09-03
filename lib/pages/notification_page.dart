import 'package:flutter/material.dart';
import 'package:luckez/models/app_notification.dart';
import 'package:luckez/repositories/notification_repository.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({
    super.key,
    required this.userId,
    required this.notificationRepository,
  });

  final String userId;
  final NotificationRepository notificationRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          '알림',
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
          TextButton(
            onPressed: () => _markAllAsRead(context),
            child: const Text(
              '전체 읽음',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageContentWidth(
          child: StreamBuilder<List<AppNotification>>(
            stream: notificationRepository.watchNotifications(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _NotificationSkeletonList();
              }

              if (snapshot.hasError) {
                return const _NotificationStateMessage(
                  icon: Icons.cloud_off_outlined,
                  message: '알림을 불러오지 못했어요',
                );
              }

              final notifications = snapshot.data ?? const <AppNotification>[];

              if (notifications.isEmpty) {
                return const _NotificationStateMessage(
                  icon: Icons.notifications_none,
                  message: '아직 알림이 없어요',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _handleNotificationTap(
                      context,
                      notification,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      try {
        await notificationRepository.markAsRead(
          userId: userId,
          notificationId: notification.id,
        );
      } catch (_) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림 처리에 실패했어요'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('연결 화면은 준비 중이에요'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    try {
      await notificationRepository.markAllAsRead(userId);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전체 읽음 처리에 실패했어요'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AppCard(
          showShadow: false,
          backgroundColor:
              isUnread ? mainColor.withValues(alpha: 0.04) : surfaceColor,
          isSelected: isUnread,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withValues(alpha: isUnread ? 0.14 : 0.08),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: mainColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.isEmpty
                                ? notification.type.label
                                : notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 15,
                              fontWeight:
                                  isUnread ? FontWeight.w900 : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

  IconData _iconForType(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.winningResult => Icons.emoji_events_outlined,
      AppNotificationType.postComment => Icons.mode_comment_outlined,
      AppNotificationType.postLike => Icons.favorite_border,
      AppNotificationType.notice => Icons.campaign_outlined,
    };
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year.$month.$day $hour:$minute';
  }
}

class _NotificationSkeletonList extends StatelessWidget {
  const _NotificationSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return AppCard(
          showShadow: false,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffECECEF),
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
                        color: const Color(0xffECECEF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xffECECEF),
                        borderRadius: BorderRadius.circular(4),
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

class _NotificationStateMessage extends StatelessWidget {
  const _NotificationStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: greyColor,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: greyColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
