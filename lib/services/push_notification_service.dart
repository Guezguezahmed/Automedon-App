import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../router.dart';

/// Service responsible for FCM permission requests, token retrieval,
/// and message reception (foreground / background tap / terminated tap).
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Requests notification permission from the user (required on Android 13+ and iOS).
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    print('Push permission granted: $granted (${settings.authorizationStatus})');
    return granted;
  }

  /// Retrieves the current FCM token for this device.
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM token: $token');
    return token;
  }

  /// Listens for token refresh events (token can change over the app's lifetime).
  void onTokenRefresh(void Function(String) callback) {
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed: $newToken');
      callback(newToken);
    });
  }

  /// Sets up listeners for foreground messages, background-tap, and
  /// checks for a terminated-launch message. Call once after the app
  /// (and router) is built.
  Future<void> setupMessageListeners() async {
    // App in foreground when message arrives: log only, no forced navigation
    // (avoids yanking the user away from what they're doing).
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground push received: ${message.data}');
    });

    // App was in background, user tapped the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Push tapped (from background): ${message.data}');
      _handleDeepLink(message.data);
    });

    // App was fully terminated, user tapped the push notification to launch it.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('Push tapped (from terminated): ${initialMessage.data}');
      _handleDeepLink(initialMessage.data);
    }
  }

  /// Parses the { type, key, ref } payload and navigates accordingly.
  void _handleDeepLink(Map<String, dynamic> data) {
    final type = data['type'];
    final refRaw = data['ref'];

    Map<String, dynamic> ref = {};
    if (refRaw is String) {
      try {
        ref = jsonDecode(refRaw) as Map<String, dynamic>;
      } catch (_) {
        return;
      }
    } else if (refRaw is Map) {
      ref = Map<String, dynamic>.from(refRaw);
    }

    if (type == 'return_due' && ref['reservation_id'] != null) {
      rootRouter?.push('/reservations/${ref['reservation_id']}');
    }
    // vignette / assurance / visite_technique: blocked pending maintenance_id endpoint
  }
}