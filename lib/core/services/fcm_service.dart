import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class FCMService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _requestPermissions();
    _setupMessageHandlers();
    _setupTokenRefresh();
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _setupTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('user_tokens').upsert({
          'user_id': userId,
          'fcm_token': newToken,
        });
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await NotificationService().showNotification(
        id: message.hashCode,
        title: notification.title ?? 'JobSy',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('App opened from notification: ${message.data}');
  }

  Future<void> saveToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      await _supabase.from('user_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> deleteToken(String userId) async {
    try {
      await _supabase.from('user_tokens').delete().eq('user_id', userId);
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}
