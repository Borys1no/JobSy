import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/core/services/notification_service.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/notifications/domain/notifications_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);
  RealtimeChannel? _channel;

  @override
  NotificationsState build() {
    ref.onDispose(() {
      _channel?.unsubscribe();
    });
    
    Future.microtask(() {
      loadNotifications();
      _subscribeToNotifications();
    });
    
    return NotificationsState.initial();
  }

  void _subscribeToNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotification = payload.newRecord;
            final notification = NotificationItem(
              id: newNotification['id'] as String,
              type: newNotification['type'] as String,
              title: newNotification['title'] as String,
              body: newNotification['body'] as String?,
              fromUserName: null,
              fromUserAvatar: null,
              isRead: false,
              createdAt: DateTime.parse(newNotification['created_at'] as String),
              chatId: newNotification['chat_id'] as String?,
            );
            
            final updated = [notification, ...state.notifications];
            state = state.copyWith(notifications: updated);
            
            // Mostrar notificación push
            NotificationService().showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: notification.title,
              body: notification.body ?? '',
              payload: notification.chatId,
            );
          },
        )
        .subscribe();
  }

  Future<void> loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final notificationsData = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (notificationsData.isEmpty) {
        state = state.copyWith(isLoading: false, notifications: []);
        return;
      }

      final notifications = notificationsData.map((n) {
        return NotificationItem(
          id: n['id'] as String,
          type: n['type'] as String,
          title: n['title'] as String,
          body: n['body'] as String?,
          fromUserName: null,
          fromUserAvatar: null,
          isRead: n['is_read'] as bool? ?? false,
          createdAt: DateTime.parse(n['created_at'] as String),
          chatId: n['chat_id'] as String?,
        );
      }).toList();

      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e) {
      print('Error cargando notificaciones: $e');
      state = state.copyWith(isLoading: false, notifications: []);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final updated = state.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationItem(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            fromUserName: n.fromUserName,
            fromUserAvatar: n.fromUserAvatar,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      state = state.copyWith(notifications: updated);
    } catch (e) {
      print('Error marcando como leída: $e');
    }
  }
}
