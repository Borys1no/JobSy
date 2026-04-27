import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobsy/features/notifications/presentation/notifications_controller.dart';

class NotificationInitializer extends ConsumerWidget {
  final Widget child;
  
  const NotificationInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Recargar notificaciones cuando se inicia sesión
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // Usuario acaba de iniciar sesión
        Future.microtask(() {
          ref.read(notificationsControllerProvider.notifier).loadNotifications();
        });
      }
    });

    return child;
  }
}
