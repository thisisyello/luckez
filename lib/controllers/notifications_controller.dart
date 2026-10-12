import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:luckez/repositories/notification_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;
  StreamSubscription<int>? _subscription;
  String? _userId;
  int _unreadCount = 0;
  int _generation = 0;
  bool _hasError = false;
  bool _isDisposed = false;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get hasError => _hasError;

  void bindUser(String? userId) {
    if (_isDisposed || _userId == userId) return;
    final generation = ++_generation;
    _subscription?.cancel();
    _subscription = null;
    _userId = userId;
    _unreadCount = 0;
    _hasError = false;
    notifyListeners();
    if (userId == null) return;

    _subscription = _repository.watchUnreadCount(userId).listen(
      (count) {
        if (!_isCurrent(generation)) return;
        _unreadCount = count;
        _hasError = false;
        notifyListeners();
      },
      onError: (Object error) {
        if (!_isCurrent(generation)) return;
        _unreadCount = 0;
        _hasError = true;
        notifyListeners();
      },
    );
  }

  bool _isCurrent(int generation) => !_isDisposed && generation == _generation;

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
