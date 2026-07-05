/// Represents the currently authenticated user.
/// Returned by POST /mobile-auth and GET /mobile-me.
///
/// Fields:
/// - [id]           : UUID of the user row in the DB.
/// - [username]     : Display name / login handle.
/// - [role]         : One of: admin | sub_office | assistant | user.
/// - [allowedPages] : null = all pages allowed; otherwise a list of page-key
///                    strings the user may access (e.g. ["fleet","reservations"]).
///                    The app may use this to hide tabs.
class AppUser {
  final String id;
  final String username;
  final String role;
  final List<String>? allowedPages;

  const AppUser({
    required this.id,
    required this.username,
    required this.role,
    this.allowedPages,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      allowedPages: json['allowed_pages'] != null
          ? List<String>.from(json['allowed_pages'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'allowed_pages': allowedPages,
      };
}
