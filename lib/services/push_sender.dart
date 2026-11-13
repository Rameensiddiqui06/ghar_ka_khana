import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PushSender {
  PushSender._();
  static final PushSender instance = PushSender._();

  static const _url = 'https://ghar-ka-khana-iota.vercel.app/api/send-push';

  /// Notifies the other party of an order. Never throws.
  Future<void> notifyOrder({
    required String orderId,
    required String title,
    required String body,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();

      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'orderId': orderId, 'title': title, 'body': body}),
      );
      debugPrint('PushSender: ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('PushSender failed: $e');
    }
  }
}