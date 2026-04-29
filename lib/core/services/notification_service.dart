import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Ref _ref;

  NotificationService(this._ref);

  Future<void> initialize() async {
    // Request permission from user
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await _setupLocalNotifications();
      await _getTokenAndSendToServer();
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);
    
    await _localNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _getTokenAndSendToServer() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        final authRepo = _ref.read(authRepositoryProvider);
        // Try to update token if user is logged in
        try {
          await authRepo.updateFcmToken(token);
        } catch (e) {
          // User might not be logged in yet, that's fine
          print('Could not update FCM token on server (User might not be logged in): $e');
        }
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        try {
          final authRepo = _ref.read(authRepositoryProvider);
          await authRepo.updateFcmToken(newToken);
        } catch (e) {
          print('Token refresh failed to update server: $e');
        }
      });
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: \${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: \${message.notification}');
      _showLocalNotification(message.notification!);
    }
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'gircik_main_channel',
      'GiyÇık Genel Bildirimler',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref));
