class NotificationsState {
  final bool isLoading;
  final List<NotificationItem> notifications;

  NotificationsState({
    required this.isLoading,
    required this.notifications,
  });

  factory NotificationsState.initial() =>
      NotificationsState(isLoading: true, notifications: const []);

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationItem>? notifications,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String? body;
  final String? fromUserName;
  final String? fromUserAvatar;
  final bool isRead;
  final DateTime createdAt;
  final String? chatId;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.fromUserName,
    this.fromUserAvatar,
    required this.isRead,
    required this.createdAt,
    this.chatId,
  });
}
