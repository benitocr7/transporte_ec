import 'package:equatable/equatable.dart';

enum LoadStatus { available, inProgress, completed, cancelled }

extension LoadStatusExtension on LoadStatus {
  String get displayName {
    switch (this) {
      case LoadStatus.available:
        return 'Disponible';
      case LoadStatus.inProgress:
        return 'En curso';
      case LoadStatus.completed:
        return 'Completado';
      case LoadStatus.cancelled:
        return 'Cancelado';
    }
  }
}

class LoadEntity extends Equatable {
  const LoadEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.vehicleType,
    required this.weightTons,
    required this.priceUsd,
    required this.cargoType,
    required this.companyName,
    required this.companyId,
    required this.status,
    this.description,
    this.isSaved = false,
  });

  final String id;
  final String origin;
  final String destination;
  final String date;
  final String vehicleType;
  final double weightTons;
  final double priceUsd;
  final String cargoType;
  final String companyName;
  final String companyId;
  final LoadStatus status;
  final String? description;
  final bool isSaved;

  LoadEntity copyWith({
    String? id,
    String? origin,
    String? destination,
    String? date,
    String? vehicleType,
    double? weightTons,
    double? priceUsd,
    String? cargoType,
    String? companyName,
    String? companyId,
    LoadStatus? status,
    String? description,
    bool? isSaved,
  }) {
    return LoadEntity(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      vehicleType: vehicleType ?? this.vehicleType,
      weightTons: weightTons ?? this.weightTons,
      priceUsd: priceUsd ?? this.priceUsd,
      cargoType: cargoType ?? this.cargoType,
      companyName: companyName ?? this.companyName,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      description: description ?? this.description,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [id, origin, destination, date, vehicleType,
        weightTons, priceUsd, cargoType, companyName, companyId, status, isSaved];
}
