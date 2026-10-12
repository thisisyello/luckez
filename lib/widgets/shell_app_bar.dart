import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    required this.photoUrl,
    required this.unreadCount,
    required this.onAccountPressed,
    required this.onNotificationsPressed,
  });

  final String? photoUrl;
  final int unreadCount;
  final VoidCallback onAccountPressed;
  final VoidCallback onNotificationsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: _ProfileIcon(photoUrl: photoUrl),
        color: textPrimaryColor,
        tooltip: '계정',
        onPressed: onAccountPressed,
      ),
      actions: [
        IconButton(
          icon: _NotificationIcon(unreadCount: unreadCount),
          color: textPrimaryColor,
          tooltip: '알림',
          onPressed: onNotificationsPressed,
        ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final label = unreadCount > 99 ? '99+' : unreadCount.toString();

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none,
              size: 22,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: surfaceColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xffF3F3F5),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return const Icon(
      Icons.account_circle_outlined,
      size: 25,
    );
  }
}
