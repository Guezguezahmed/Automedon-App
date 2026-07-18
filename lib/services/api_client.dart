import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionExpiredException implements Exception {}

class ApiClient {
  // Injected via --dart-define
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://supabase-api.cherifcorp.com/functions/v1',
  );
  static const String tenantSlug = String.fromEnvironment(
    'TENANT_SLUG',
    defaultValue: 'demo',
  );

  String? token;
  final _storage = const FlutterSecureStorage();

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<void> init() async {
    token = await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> login(String slug, String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/mobile-auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'slug': slug, 'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Login failed');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    token = data['token'] as String;
    await _storage.write(key: 'jwt_token', value: token);
    return data;
  }

  Future<void> logout() async {
    token = null;
    await _storage.delete(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 401) throw SessionExpiredException();
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Request failed');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() => _get('/mobile-me');

  Future<Map<String, dynamic>> getVision360({int days = 14}) =>
      _get('/mobile-vision360', {'days': '$days'});

  Future<Map<String, dynamic>> getCars({String? status}) =>
      _get('/mobile-cars', status != null ? {'status': status} : null);

  Future<Map<String, dynamic>> getReservations({int page = 1, int pageSize = 20, String? status}) =>
      _get('/mobile-reservations', {
        'page': '$page',
        'pageSize': '$pageSize',
        if (status != null) 'status': status,
      });

  Future<Map<String, dynamic>> getReservationDetail(int id) =>
      _get('/mobile-reservations', {'id': '$id'});

  Future<Map<String, dynamic>> getNotifications() => _get('/mobile-notifications');
}