import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/supabase_client.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_background_handler.dart';
import 'core/services/fcm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  print('Supabase initialized: ${Supabase.instance.client.auth.currentSession}');

  await NotificationService().initialize();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized');
    
    // CRÍTICO: Configurar manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  } catch (e) {
    print('Firebase error: $e');
  }

  await FCMService().initialize();

  runApp(const ProviderScope(child: JobSyApp()));
}
