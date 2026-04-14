import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/notifications/domain/notifications_state.dart';
import 'package:jobsy/features/notifications/presentation/notifications_controller.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications,
                    size: 48,
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'JobSy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            )
          : state.notifications.isEmpty
          ? _buildEmptyState(isDark, subColor)
          : _buildNotificationsList(
              context,
              ref,
              state.notifications,
              isDark,
              cardColor,
              textColor,
              subColor,
              borderColor,
            ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none, size: 60, color: subColor),
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí aparecerán tus notificaciones',
            style: TextStyle(
              fontSize: 14,
              color: subColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationItem> notifications,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          notification: notification,
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subColor: subColor,
          borderColor: borderColor,
          onTap: () {
            if (!notification.isRead) {
              ref
                  .read(notificationsControllerProvider.notifier)
                  .markAsRead(notification.id);
            }
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? cardColor
            : AppTheme.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? borderColor
              : AppTheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForType(notification.type),
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      if (notification.fromUserName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.fromUserName!,
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: TextStyle(color: subColor, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          color: subColor.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'job':
        return Icons.work_outline;
      case 'review':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
