/// Reference data attached to a notification, allowing deep-linking.
/// Shape depends on the notification [type]:
///   - return_due  → { reservation_id, car }
///   - vignette / assurance / visite_technique → { maintenance_id, car, paper }
class NotificationRef {
  final int? reservationId;
  final int? maintenanceId;
  final String? car;
  final String? paper;

  const NotificationRef({
    this.reservationId,
    this.maintenanceId,
    this.car,
    this.paper,
  });

  factory NotificationRef.fromJson(Map<String, dynamic> json) {
    return NotificationRef(
      reservationId: json['reservation_id'] as int?,
      maintenanceId: json['maintenance_id'] as int?,
      car: json['car'] as String?,
      paper: json['paper'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (reservationId != null) 'reservation_id': reservationId,
        if (maintenanceId != null) 'maintenance_id': maintenanceId,
        if (car != null) 'car': car,
        if (paper != null) 'paper': paper,
      };
}

/// A single item in the notification feed from GET /mobile-notifications.
///
/// Fields:
/// - [key]      : Stable unique id (e.g. "return:501:2026-07-02T10:00:00.000Z").
///                Use for de-duplication and local "mark as read" tracking.
/// - [type]     : "return_due" | "vignette" | "assurance" | "visite_technique".
/// - [title]    : Short French title for the notification card.
/// - [message]  : Full descriptive text.
/// - [date]     : ISO 8601 due date (can be date-only for paper expiries).
/// - [daysLeft] : Days until [date]. Negative = already overdue.
/// - [severity] : "info" | "warning" | "danger" — drives card color/icon.
/// - [ref]      : Optional metadata for deep-linking to the related resource.
class AppNotification {
  final String key;
  final String type;
  final String title;
  final String message;
  final String date;
  final int daysLeft;
  final String severity;
  final NotificationRef? ref;

  const AppNotification({
    required this.key,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.daysLeft,
    required this.severity,
    this.ref,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      key: json['key'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      date: json['date'] as String,
      daysLeft: json['daysLeft'] as int,
      severity: json['severity'] as String,
      ref: json['ref'] != null
          ? NotificationRef.fromJson(json['ref'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type,
        'title': title,
        'message': message,
        'date': date,
        'daysLeft': daysLeft,
        'severity': severity,
        'ref': ref?.toJson(),
      };
}

/// Top-level response from GET /mobile-notifications.
///
/// - [notifications] : Sorted most-urgent first.
/// - [unread]        : Count of unread/new notifications.
/// - [generatedAt]   : ISO 8601 timestamp when this feed was computed.
class NotificationsResponse {
  final List<AppNotification> notifications;
  final int unread;
  final String generatedAt;

  const NotificationsResponse({
    required this.notifications,
    required this.unread,
    required this.generatedAt,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['notifications'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unread: json['unread'] as int,
      generatedAt: json['generated_at'] as String,
    );
  }
}
