import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

const debugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      providerWeb: kDebugMode
          ? WebDebugProvider(
        debugToken: debugToken.isEmpty ? null : debugToken,
      )
          : ReCaptchaV3Provider('PASTE_SITE_KEY_HERE'),
      providerAndroid: kDebugMode
          ? AndroidDebugProvider(
        debugToken: debugToken.isEmpty ? null : debugToken,
      )
          : const AndroidPlayIntegrityProvider(),
    );
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }

  if (NotificationService.isSupported) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init(onTap: (data) {
      // e.g. data['orderId'] -> navigate to order details
    });
  }

  runApp(const GharKaKhanaApp());
}