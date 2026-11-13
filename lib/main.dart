import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (NotificationService.isSupported) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init(onTap: (data) {
      // e.g. data['orderId'] -> navigate to order details
    });
  }

  runApp(const GharKaKhanaApp());
}


// // import 'package:flutter/material.dart';
// // import 'app.dart';
//
// // void main() {
// //   runApp(const GharKaKhanaApp());
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'app.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'services/notification_service.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   await NotificationService.instance.init(onTap: (data) {
//     // e.g. data['orderId'] -> navigate to order details
//   });
//   runApp(const GharKaKhanaApp());
// }


