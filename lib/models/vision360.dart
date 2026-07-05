import 'car.dart';

/// A single timeline entry from GET /mobile-vision360.
/// Represents a reservation overlapping the requested date window.
///
/// Fields:
/// - [id]         : Reservation DB id.
/// - [carId]      : FK to the car.
/// - [startDate]  : ISO 8601 rental start.
/// - [endDate]    : ISO 8601 planned return.
/// - [clientName] : Name of the renting client.
/// - [status]     : Reservation status (e.g. "active", "confirmed").
class TimelineEntry {
  final int id;
  final int carId;
  final String startDate;
  final String endDate;
  final String clientName;
  final String status;

  const TimelineEntry({
    required this.id,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.clientName,
    required this.status,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      id: json['id'] as int,
      carId: json['car_id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      clientName: json['client_name'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
        'client_name': clientName,
        'status': status,
      };
}

/// A car actively rented and expected to be returned soon.
/// From the [returningSoon] list in GET /mobile-vision360.
/// Sorted by soonest [endDate] first.
///
/// Fields:
/// - [carId]       : FK to the car.
/// - [brand]       : Car make.
/// - [model]       : Car model.
/// - [plateNumber] : Registration plate.
/// - [clientName]  : Current renter's name.
/// - [endDate]     : ISO 8601 planned return date.
class ReturningSoonEntry {
  final int carId;
  final String brand;
  final String model;
  final String? plateNumber;
  final String clientName;
  final String endDate;

  const ReturningSoonEntry({
    required this.carId,
    required this.brand,
    required this.model,
    this.plateNumber,
    required this.clientName,
    required this.endDate,
  });

  factory ReturningSoonEntry.fromJson(Map<String, dynamic> json) {
    return ReturningSoonEntry(
      carId: json['car_id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      plateNumber: json['plate_number'] as String?,
      clientName: json['client_name'] as String,
      endDate: json['end_date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'car_id': carId,
        'brand': brand,
        'model': model,
        'plate_number': plateNumber,
        'client_name': clientName,
        'end_date': endDate,
      };
}

/// Time window metadata included in GET /mobile-vision360.
class Vision360Window {
  final String start;
  final String end;
  final int days;

  const Vision360Window({
    required this.start,
    required this.end,
    required this.days,
  });

  factory Vision360Window.fromJson(Map<String, dynamic> json) {
    return Vision360Window(
      start: json['start'] as String,
      end: json['end'] as String,
      days: json['days'] as int,
    );
  }
}

/// Top-level response from GET /mobile-vision360.
/// Powers the dashboard / planning screen.
///
/// - [window]        : The date window that was queried.
/// - [cars]          : Full fleet list (same shape as GET /mobile-cars).
/// - [timeline]      : Reservations overlapping the window.
/// - [returningSoon] : Active rentals sorted by soonest return.
class Vision360Response {
  final Vision360Window window;
  final List<Car> cars;
  final List<TimelineEntry> timeline;
  final List<ReturningSoonEntry> returningSoon;

  const Vision360Response({
    required this.window,
    required this.cars,
    required this.timeline,
    required this.returningSoon,
  });

  factory Vision360Response.fromJson(Map<String, dynamic> json) {
    return Vision360Response(
      window: Vision360Window.fromJson(json['window'] as Map<String, dynamic>),
      cars: (json['cars'] as List)
          .map((e) => Car.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: (json['timeline'] as List)
          .map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      returningSoon: (json['returningSoon'] as List)
          .map((e) => ReturningSoonEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
