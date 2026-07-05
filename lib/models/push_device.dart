/// Request body for POST /mobile-notifications — register push device.
/// Call after login and whenever the FCM token refreshes.
///
/// Fields:
/// - [pushToken] : FCM/APNS/Expo device push token.
/// - [platform]  : "android" | "ios" (optional, default "expo").
/// - [provider]  : "fcm" | "apns" | "expo" (optional, default "expo").
class PushDeviceRequest {
  final String pushToken;
  final String? platform;
  final String? provider;

  const PushDeviceRequest({
    required this.pushToken,
    this.platform,
    this.provider,
  });

  Map<String, dynamic> toJson() => {
        'push_token': pushToken,
        if (platform != null) 'platform': platform,
        if (provider != null) 'provider': provider,
      };
}

/// Payload included in a server-sent push notification.
/// Allows the app to deep-link to the relevant screen.
///
/// Fields:
/// - [type] : Same values as [AppNotification.type].
/// - [key]  : Stable unique id matching the in-app feed.
/// - [ref]  : Optional reference data for deep-linking.
class PushPayload {
  final String type;
  final String key;
  final Map<String, dynamic>? ref;

  const PushPayload({
    required this.type,
    required this.key,
    this.ref,
  });

  factory PushPayload.fromJson(Map<String, dynamic> json) {
    return PushPayload(
      type: json['type'] as String,
      key: json['key'] as String,
      ref: json['ref'] as Map<String, dynamic>?,
    );
  }
}
