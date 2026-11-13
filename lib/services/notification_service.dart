import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  /// Push notifications only work on Android and iOS.
  static bool get isSupported =>
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
  void Function(Map<String, dynamic> data)? _onTap;

  static const _channel = AndroidNotificationChannel(
    'orders_channel',
    'Order updates',
    description: 'Order updates and offers',
    importance: Importance.high,
  );

  Future<void> init({
    required void Function(Map<String, dynamic> data) onTap,
  }) async {
    if (!isSupported) return;
    _onTap = onTap;

    final settings = await _fcm.requestPermission();
    debugPrint('Permission: ${settings.authorizationStatus}');

    try {
      final token = await _fcm.getToken();
      debugPrint('FCM TOKEN: $token');
    } catch (e) {
      debugPrint('getToken FAILED: $e');
    }

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null && r.payload!.isNotEmpty) {
          _onTap?.call(jsonDecode(r.payload!) as Map<String, dynamic>);
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // App open: show a banner ourselves (FCM doesn't on Android)
    FirebaseMessaging.onMessage.listen((m) {
      debugPrint('FOREGROUND message: ${m.notification?.title} / ${m.notification?.body}');
      _showForeground(m).catchError((e) => debugPrint('show failed: $e'));
    });

    // User taps a notification while app is in background / closed
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _onTap?.call(m.data));
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _onTap?.call(initial.data);

    // Keep the device token saved for the logged-in user
    _fcm.onTokenRefresh.listen(_saveToken);
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;
      try {
        await _saveToken(await _fcm.getToken());
      } catch (e) {
        debugPrint('Token save failed: $e');
      }
    });
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null) return;
    await _local.show(
      id: n.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(m.data),
    );
  }
  /// Public: saves this device's token for the current user.
  /// Safe to call on web or if anything fails; it never throws.
  Future<void> saveToken() async {
    if (!isSupported) return;
    try {
      await _saveToken(await _fcm.getToken());
    } catch (_) {}
  }
  Future<void> _saveToken(String? token) async {
    debugPrint('FCM token: $token');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> removeToken() async {
    if (!isSupported) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final token = await _fcm.getToken();
      if (uid == null || token == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
