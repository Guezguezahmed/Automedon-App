/// A compact snapshot of a reservation attached to a car object.
/// Appears inside [Car.activeReservation] and [Car.nextReservation].
///
/// For [activeReservation]: all fields are present.
/// For [nextReservation]  : only [startDate] and [endDate] are guaranteed.
class CarReservationSnapshot {
  final String startDate;
  final String endDate;
  final String? clientName;
  final String? contractNumber;
  final String? status;
  final num? totalPrice;
  final num? advancePayment;

  const CarReservationSnapshot({
    required this.startDate,
    required this.endDate,
    this.clientName,
    this.contractNumber,
    this.status,
    this.totalPrice,
    this.advancePayment,
  });

  factory CarReservationSnapshot.fromJson(Map<String, dynamic> json) {
    return CarReservationSnapshot(
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      clientName: json['client_name'] as String?,
      contractNumber: json['contract_number'] as String?,
      status: json['status'] as String?,
      totalPrice: json['total_price'] as num?,
      advancePayment: json['advance_payment'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate,
        'end_date': endDate,
        'client_name': clientName,
        'contract_number': contractNumber,
        'status': status,
        'total_price': totalPrice,
        'advance_payment': advancePayment,
      };
}

/// Represents a single vehicle in the fleet.
/// Returned by GET /mobile-cars and embedded in GET /mobile-vision360.
///
/// Fields:
/// - [id]                    : Numeric DB id of the car.
/// - [brand]                 : Make/manufacturer (e.g. "Dacia").
/// - [model]                 : Model name (e.g. "Logan").
/// - [plateNumber]           : Registration plate (e.g. "123 TUN 4567").
/// - [status]                : "disponible" | "loue" | "maintenance".
/// - [imageUrl]              : Optional photo URL.
/// - [transmission]          : "manual" | "automatic" | null.
/// - [mileage]               : Current odometer reading in km.
/// - [firstRegistrationYear] : Year the car was first registered.
/// - [isSousTraitance]       : true if the car belongs to a subcontract partner.
/// - [sousTraitanceName]     : Name of the subcontract partner (null if not sous-traitance).
/// - [activeReservation]     : The current active rental snapshot, or null.
/// - [nextReservation]       : The nearest future booking dates, or null.
class Car {
  final int id;
  final String brand;
  final String model;
  final String? plateNumber;
  final String status;
  final String? imageUrl;
  final String? transmission;
  final int? mileage;
  final int? firstRegistrationYear;
  final bool? isSousTraitance;
  final String? sousTraitanceName;
  final CarReservationSnapshot? activeReservation;
  final CarReservationSnapshot? nextReservation;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    this.plateNumber,
    required this.status,
    this.imageUrl,
    this.transmission,
    this.mileage,
    this.firstRegistrationYear,
    this.isSousTraitance,
    this.sousTraitanceName,
    this.activeReservation,
    this.nextReservation,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      plateNumber: json['plate_number'] as String?,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      transmission: json['transmission'] as String?,
      mileage: json['mileage'] as int?,
      firstRegistrationYear: json['first_registration_year'] as int?,
      isSousTraitance: json['is_sous_traitance'] as bool?,
      sousTraitanceName: json['sous_traitance_name'] as String?,
      activeReservation: json['active_reservation'] != null
          ? CarReservationSnapshot.fromJson(
              json['active_reservation'] as Map<String, dynamic>)
          : null,
      nextReservation: json['next_reservation'] != null
          ? CarReservationSnapshot.fromJson(
              json['next_reservation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'plate_number': plateNumber,
        'status': status,
        'image_url': imageUrl,
        'transmission': transmission,
        'mileage': mileage,
        'first_registration_year': firstRegistrationYear,
        'is_sous_traitance': isSousTraitance,
        'sous_traitance_name': sousTraitanceName,
        'active_reservation': activeReservation?.toJson(),
        'next_reservation': nextReservation?.toJson(),
      };
}

/// Aggregate counts returned alongside the car list.
/// From the [counts] field in GET /mobile-cars.
class FleetCounts {
  final int total;
  final int disponible;
  final int loue;
  final int maintenance;

  const FleetCounts({
    required this.total,
    required this.disponible,
    required this.loue,
    required this.maintenance,
  });

  factory FleetCounts.fromJson(Map<String, dynamic> json) {
    return FleetCounts(
      total: json['total'] as int,
      disponible: json['disponible'] as int,
      loue: json['loue'] as int,
      maintenance: json['maintenance'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'disponible': disponible,
        'loue': loue,
        'maintenance': maintenance,
      };
}

/// Top-level response from GET /mobile-cars.
class CarsResponse {
  final List<Car> cars;
  final FleetCounts counts;

  const CarsResponse({required this.cars, required this.counts});

  factory CarsResponse.fromJson(Map<String, dynamic> json) {
    return CarsResponse(
      cars: (json['cars'] as List)
          .map((e) => Car.fromJson(e as Map<String, dynamic>))
          .toList(),
      counts: FleetCounts.fromJson(json['counts'] as Map<String, dynamic>),
    );
  }
}
