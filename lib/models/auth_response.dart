import 'app_user.dart';
import 'tenant.dart';

/// Top-level response from POST /mobile-auth (login).
///
/// Fields:
/// - [token]  : Bearer JWT valid for 30 days. Store with flutter_secure_storage.
/// - [user]   : Authenticated user details.
/// - [tenant] : The company/agency this user belongs to.
class AuthResponse {
  final String token;
  final AppUser user;
  final Tenant tenant;

  const AuthResponse({
    required this.token,
    required this.user,
    required this.tenant,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      tenant: Tenant.fromJson(json['tenant'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
        'tenant': tenant.toJson(),
      };
}
