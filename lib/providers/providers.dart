import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
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
  }

  Future<void> logout() async {
    final client = ref.read(apiClientProvider);
    await client.logout();
    state = false;
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

final reservationsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, status) async {
  return ref.watch(apiClientProvider).getReservations(status: status);
});

final notificationsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(apiClientProvider).getNotifications();
});
