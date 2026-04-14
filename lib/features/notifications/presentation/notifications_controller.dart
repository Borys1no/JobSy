import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/notifications/domain/notifications_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  NotificationsState build() {
    Future.microtask(() => loadNotifications());
    return NotificationsState.initial();
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
          .select('''
            id,
            type,
            title,
            body,
            is_read,
            created_at,
            from_user:profiles(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      List<NotificationItem> notifications;
      if (notificationsData.isEmpty) {
        notifications = _getStaticNotifications();
      } else {
        notifications = notificationsData.map((n) {
          final fromUser = n['from_user'] as Map<String, dynamic>? ?? {};
          return NotificationItem(
            id: n['id'] as String,
            type: n['type'] as String,
            title: n['title'] as String,
            body: n['body'] as String?,
            fromUserName:
                '${fromUser['first_name'] ?? ''} ${fromUser['last_name'] ?? ''}'
                    .trim(),
            fromUserAvatar: fromUser['avatar_url'] as String?,
            isRead: n['is_read'] as bool? ?? false,
            createdAt: DateTime.parse(n['created_at'] as String),
          );
        }).toList();
      }

      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e) {
      print('Error cargando notificaciones: $e');
      state = state.copyWith(
        isLoading: false,
        notifications: _getStaticNotifications(),
      );
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

  List<NotificationItem> _getStaticNotifications() {
    return [
      NotificationItem(
        id: '1',
        type: 'message',
        title: 'Nuevo mensaje',
        body: 'Juan te ha enviado un mensaje',
        fromUserName: 'Juan Pérez',
        fromUserAvatar: null,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      NotificationItem(
        id: '2',
        type: 'job',
        title: 'Nuevo trabajo asignado',
        body: 'María García te ha contratado para limpieza',
        fromUserName: 'María García',
        fromUserAvatar: null,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '3',
        type: 'review',
        title: 'Nueva reseña',
        body: 'Ana López te ha calificado',
        fromUserName: 'Ana López',
        fromUserAvatar: null,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: '4',
        type: 'job',
        title: 'Trabajo completado',
        body: 'El trabajo de pintura ha sido marcado como completado',
        fromUserName: 'Carlos Martínez',
        fromUserAvatar: null,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationItem(
        id: '5',
        type: 'message',
        title: 'Nuevo mensaje',
        body: 'Laura te ha escrito sobre el presupuesto',
        fromUserName: 'Laura Sánchez',
        fromUserAvatar: null,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
