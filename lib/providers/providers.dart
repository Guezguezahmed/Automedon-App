import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/push_notification_service.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  client.onSessionExpired = () {
    ref.read(authProvider.notifier).logout();
  };
  return client;

});

// Push Notification Service Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

// Auth State Provider
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    final client = ref.read(apiClientProvider);
    await client.init();
    if (client.token != null) {
      state = true;
    }
  }

  Future<void> login(String slug, String username, String password) async {
    final client = ref.read(apiClientProvider);
    await client.login(slug, username, password);
    state = true;
    await _registerPushToken();
  }

  Future<void> logout() async {
    await _unregisterPushToken();
    final client = ref.read(apiClientProvider);
    await client.logout();
    state = false;
  }

  Future<void> _registerPushToken() async {
    try {
      final pushService = ref.read(pushNotificationServiceProvider);
      final granted = await pushService.requestPermission();
      if (!granted) return;
      final fcmToken = await pushService.getToken();
      if (fcmToken == null) return;
      final client = ref.read(apiClientProvider);
      await client.registerPush(fcmToken);
      print('Push token registered successfully');
    } catch (e) {
      print('Push token registration failed: $e');
    }
  }

  Future<void> _unregisterPushToken() async {
    try {
      final pushService = ref.read(pushNotificationServiceProvider);
      final fcmToken = await pushService.getToken();
      if (fcmToken == null) return;
      final client = ref.read(apiClientProvider);
      await client.unregisterPush(fcmToken);
      print('Push token unregistered successfully');
    } catch (e) {
      print('Push token unregistration failed: $e');
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

// Data Providers
final meProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(apiClientProvider).getMe();
});

final vision360Provider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(apiClientProvider).getVision360();
});

final carsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, status) async {
  return ref.watch(apiClientProvider).getCars(status: status);
});

class ReservationsParams {
  final String? status;
  final int page;

  const ReservationsParams({this.status, this.page = 1});

  @override
  bool operator ==(Object other) =>
      other is ReservationsParams && other.status == status && other.page == page;

  @override
  int get hashCode => Object.hash(status, page);
}

final reservationsProvider = FutureProvider.family<Map<String, dynamic>, ReservationsParams>((ref, params) async {
  return ref.watch(apiClientProvider).getReservations(status: params.status, page: params.page);
});
final reservationDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  return ref.watch(apiClientProvider).getReservationDetail(id);
});
final notificationsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(apiClientProvider).getNotifications();
});

// ── Local UI state (no API backing) ─────────────────────────────────────────
/// Whether the user has enabled push notifications (persists for the session).
class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle(bool value) => state = value;
}
final notificationsEnabledProvider =
NotifierProvider<NotificationsEnabledNotifier, bool>(
    NotificationsEnabledNotifier.new);

/// Currently selected UI language: 'FR' or 'AR'.
class SelectedLanguageNotifier extends Notifier<String> {
  @override
  String build() => 'FR';
  void select(String lang) => state = lang;
}
final selectedLanguageProvider =
NotifierProvider<SelectedLanguageNotifier, String>(
    SelectedLanguageNotifier.new);

/// Theme Mode state: ThemeMode.dark (default) or ThemeMode.light.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;
  void toggle(bool isDark) => state = isDark ? ThemeMode.dark : ThemeMode.light;
  void setThemeMode(ThemeMode mode) => state = mode;
}
final themeModeProvider =
NotifierProvider<ThemeModeNotifier, ThemeMode>(
    ThemeModeNotifier.new);