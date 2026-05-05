import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

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
