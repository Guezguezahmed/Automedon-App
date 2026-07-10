import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionExpiredException implements Exception {}

class ApiClient {
  // Configurable base URL (not used in mock mode)
  final String projectRef = 'MOCK_PROJECT_REF'; 
  late final String baseUrl;
  
  String? token;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    baseUrl = 'https://$projectRef.supabase.co/functions/v1';
  }

  Future<void> init() async {
    token = await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> login(String slug, String username, String password) async {
    // MOCK LOGIN
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay
    token = 'mock_jwt_token_12345';
    await _storage.write(key: 'jwt_token', value: token);
    return {'token': token, 'user': {'username': username}};
  }

  Future<void> logout() async {
    token = null;
    await _storage.delete(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> getMe() async {
    // MOCK ME
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'user': {
        'id': 'u1',
        'username': 'Mehdi Tlili',
        'role': 'admin',
      },
      'tenant': {
        'id': 't1',
        'slug': 'Cherif-Rent-Car',
        'name': 'AutoLocation Tunis',
        'status': 'active'
      }
    };
  }

  Future<Map<String, dynamic>> getVision360({int days = 14}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    final rentalEnd = now.add(const Duration(days: 1)); // "Retour Demain"

    return {
      'window': {
        'start': now.toIso8601String(),
        'end': end.toIso8601String(),
        'days': days,
      },
      'cars': [
        {
          'id': 12,
          'brand': 'Hyundai',
          'model': 'I20',
          'plate_number': '247 TN 5433',
          'status': 'loue',
          'active_reservation': {
            'client_name': 'mohamed',
            'start_date': now.subtract(const Duration(days: 6)).toIso8601String(),
            'end_date': rentalEnd.toIso8601String(),
            'total_price': 900,
            'advance_payment': 400,
          },
        },
        {'id': 21, 'brand': 'Dacia', 'model': 'Sindero', 'plate_number': '237 TU 4530', 'status': 'disponible'},
        {'id': 22, 'brand': 'Hyundai', 'model': 'I20', 'plate_number': '257 TU 3965', 'status': 'disponible'},
        {'id': 23, 'brand': 'Renault', 'model': 'CLIO 5', 'plate_number': '247 TN 6228', 'status': 'disponible'},
        {'id': 24, 'brand': 'Skoda', 'model': 'KUSHAQ', 'plate_number': '252 TN 9505', 'status': 'disponible'},
        {'id': 25, 'brand': 'Suzuki', 'model': 'Ciaz', 'plate_number': '242 TN 7442', 'status': 'disponible'},
        {'id': 26, 'brand': 'Volkswagen', 'model': 'Virtus', 'plate_number': '239 TN 5845', 'status': 'disponible'},
        {'id': 27, 'brand': 'Volkswagen', 'model': 'Virtus', 'plate_number': '239 TN 5844', 'status': 'disponible'},
      ],
      'timeline': [
        {
          'id': 501,
          'car_id': 12,
          'start_date': now.subtract(const Duration(days: 6)).toIso8601String(),
          'end_date': rentalEnd.toIso8601String(),
          'client_name': 'mohamed',
          'status': 'active',
        },
      ],
      'returningSoon': [
        {
          'car_id': 12,
          'brand': 'Hyundai',
          'model': 'I20',
          'plate_number': '247 TN 5433',
          'client_name': 'mohamed',
          'end_date': rentalEnd.toIso8601String(),
        },
      ],
    };
  }

  Future<Map<String, dynamic>> getCars({String? status}) async {
    // MOCK CARS
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'cars': [
        {
          'id': 1,
          'brand': 'BMW',
          'model': 'Série 3',
          'plate_number': 'TU 789 33',
          'first_registration_year': 2021,
          'mileage': 48200,
          'status': 'disponible',
        },
        {
          'id': 2,
          'brand': 'Mercedes',
          'model': 'Classe C',
          'plate_number': 'TU 800 22',
          'first_registration_year': 2022,
          'mileage': 32000,
          'status': 'loue',
        },
        {
          'id': 3,
          'brand': 'Audi',
          'model': 'A4',
          'plate_number': 'TU 755 11',
          'first_registration_year': 2020,
          'mileage': 55000,
          'status': 'maintenance',
        }
      ]
    };
  }

  Future<Map<String, dynamic>> getReservations({int page = 1, int pageSize = 20, String? status}) async {
    // MOCK RESERVATIONS
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'reservations': [
        {
          'id': 1,
          'client_name': 'Amine Mansour',
          'contract_number': 'R-2024-003',
          'status': status ?? 'active',
          'total_price': 340,
          'car': {
            'brand': 'Dacia',
            'model': 'Logan',
          }
        },
        {
          'id': 2,
          'client_name': 'Sarra Ben Ali',
          'contract_number': 'R-2024-004',
          'status': status ?? 'active',
          'total_price': 450,
          'car': {
            'brand': 'Renault',
            'model': 'Symbol',
          }
        }
      ]
    };
  }

  Future<Map<String, dynamic>> getNotifications() async {
    // MOCK NOTIFICATIONS
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'notifications': [
        {
          'title': 'Retour prévu aujourd\'hui',
          'message': 'Peugeot 208 (Mohamed Ali) doit être rendue à 14h.',
          'date': 'Il y a 10 min',
          'severity': 'warning'
        },
        {
          'title': 'Contrat signé',
          'message': 'Sami Ahmed a signé le contrat R-2024-005.',
          'date': 'Hier, 14h30',
          'severity': 'success'
        },
        {
          'title': 'Maintenance requise',
          'message': 'Vidange à faire sur Audi A4 (TU 755 11).',
          'date': 'Il y a 2 jours',
          'severity': 'danger'
        },
      ]
    };
  }
}
