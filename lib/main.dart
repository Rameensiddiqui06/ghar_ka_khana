

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

const debugToken =
    String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  runApp(const GharKaKhanaApp());
}
