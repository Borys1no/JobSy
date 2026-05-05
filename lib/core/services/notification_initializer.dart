import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobsy/core/services/fcm_service.dart';
import 'package:jobsy/features/notifications/presentation/notifications_controller.dart';

class NotificationInitializer extends ConsumerWidget {
  final Widget child;
  
  const NotificationInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Recargar notificaciones cuando se inicia sesión
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;
      
      if (session != null) {
        // Usuario acaba de iniciar sesión
        Future.microtask(() async {
          ref.read(notificationsControllerProvider.notifier).loadNotifications();
          await FCMService().saveToken(session.user.id);
        });
      }
      
      if (event == AuthChangeEvent.signedOut) {
        // Obtener el user_id antes de que se borre la sesión
        final userId = session?.user.id ?? Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await FCMService().deleteToken(userId);
        }
      }
    });

    return child;
  }
}
