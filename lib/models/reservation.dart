/// Compact car info embedded inside a [Reservation] object.
///
/// Fields:
/// - [id]           : Car DB id (only present in detail response).
/// - [brand]        : Make/manufacturer.
/// - [model]        : Model name.
/// - [licensePlate] : Registration plate (key is "license_plate" in API).
/// - [imageUrl]     : Optional photo URL.
class ReservationCar {
  final int? id;
  final String brand;
  final String model;
  final String? licensePlate;
  final String? imageUrl;

  const ReservationCar({
    this.id,
    required this.brand,
    required this.model,
    this.licensePlate,
    this.imageUrl,
  });

  factory ReservationCar.fromJson(Map<String, dynamic> json) {
    return ReservationCar(
      id: json['id'] as int?,
      brand: json['brand'] as String,
      model: json['model'] as String,
      licensePlate: json['license_plate'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'brand': brand,
        'model': model,
        'license_plate': licensePlate,
        'image_url': imageUrl,
      };
}

/// Represents a single reservation/rental contract.
/// Returned by GET /mobile-reservations (list and detail modes).
///
/// Fields:
/// - [id]                 : Numeric DB id.
/// - [reservationNumber]  : Human-readable ref (e.g. "RES-1717000000000").
/// - [clientName]         : Full name of the renting client.
/// - [clientPhone]        : Contact phone number.
/// - [carId]              : FK to the car (only in list response).
/// - [startDate]          : ISO 8601 rental start.
/// - [endDate]            : ISO 8601 planned return.
/// - [status]             : "confirmed" | "active" | "completed" | "cancelled".
/// - [totalPrice]         : Full rental price in TND.
/// - [advancePayment]     : Deposit/advance paid in TND.
/// - [contractNumber]     : Signed contract reference (e.g. "CT-1024").
/// - [createdAt]          : ISO 8601 creation timestamp.
/// - [car]                : Embedded car snapshot.
class Reservation {
  final int id;
  final String? reservationNumber;
  final String clientName;
  final String? clientPhone;
  final int? carId;
  final String startDate;
  final String endDate;
  final String status;
  final num? totalPrice;
  final num? advancePayment;
  final String? contractNumber;
  final String? createdAt;
  final ReservationCar? car;

  const Reservation({
    required this.id,
    this.reservationNumber,
    required this.clientName,
    this.clientPhone,
    this.carId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.totalPrice,
    this.advancePayment,
    this.contractNumber,
    this.createdAt,
    this.car,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      reservationNumber: json['reservation_number'] as String?,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String?,
      carId: json['car_id'] as int?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
      totalPrice: json['total_price'] as num?,
      advancePayment: json['advance_payment'] as num?,
      contractNumber: json['contract_number'] as String?,
      createdAt: json['created_at'] as String?,
      car: json['car'] != null
          ? ReservationCar.fromJson(json['car'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reservation_number': reservationNumber,
        'client_name': clientName,
        'client_phone': clientPhone,
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'total_price': totalPrice,
        'advance_payment': advancePayment,
        'contract_number': contractNumber,
        'created_at': createdAt,
        'car': car?.toJson(),
      };
}

/// Paginated list response from GET /mobile-reservations.
class ReservationsListResponse {
  final List<Reservation> reservations;
  final int total;
  final int page;
  final int pageSize;

  const ReservationsListResponse({
    required this.reservations,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ReservationsListResponse.fromJson(Map<String, dynamic> json) {
    return ReservationsListResponse(
      reservations: (json['reservations'] as List)
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  /// Total number of pages given the current pageSize.
  int get totalPages => (total / pageSize).ceil();
}
