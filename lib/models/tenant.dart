/// Represents the agency/company (tenant) this user belongs to.
/// Returned by POST /mobile-auth and GET /mobile-me.
///
/// Fields:
/// - [id]      : UUID of the tenant row.
/// - [slug]    : URL-safe identifier used in the web app (e.g. "Cherif-Rent-Car").
/// - [name]    : Human-readable company name.
/// - [logoUrl] : Optional URL to the agency logo image.
/// - [status]  : "active" | "suspended" | etc.
class Tenant {
  final String id;
  final String slug;
  final String name;
  final String? logoUrl;
  final String status;

  const Tenant({
    required this.id,
    required this.slug,
    required this.name,
    this.logoUrl,
    required this.status,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'logo_url': logoUrl,
        'status': status,
      };
}
