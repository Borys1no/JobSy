import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
