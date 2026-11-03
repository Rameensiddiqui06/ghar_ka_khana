

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase options have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase options have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase options have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options have not been configured for Linux.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options have not been configured for Fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRsaa7UNqST6P-0K27YYHWxNRN6pnZtZk',
    appId: '1:554321796922:android:d1e8b5d76d50adfdc13a03',
    messagingSenderId: '554321796922',
    projectId: 'ghar-ka-khana-cda7a',
    storageBucket: 'ghar-ka-khana-cda7a.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBm7_KGVwpMy4SmF80srVDk6HNKHwC-tyY',
    appId: '1:554321796922:web:95e300ce628212f7c13a03',
    messagingSenderId: '554321796922',
    projectId: 'ghar-ka-khana-cda7a',
    authDomain: 'ghar-ka-khana-cda7a.firebaseapp.com',
    storageBucket: 'ghar-ka-khana-cda7a.firebasestorage.app',
  );
}
