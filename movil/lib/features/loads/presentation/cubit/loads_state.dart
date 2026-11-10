import 'package:equatable/equatable.dart';
import '../../domain/load_entity.dart';

abstract class LoadsState extends Equatable {
  const LoadsState();
  @override
  List<Object?> get props => [];
}

class LoadsInitial extends LoadsState {
  const LoadsInitial();
}

class LoadsLoading extends LoadsState {
  const LoadsLoading();
}

class LoadsLoaded extends LoadsState {
  const LoadsLoaded({
    required this.loads,
    this.query = '',
    this.filterOrigin,
    this.filterDestination,
    this.filterVehicle,
  });

  final List<LoadEntity> loads;
  final String query;
  final String? filterOrigin;
  final String? filterDestination;
  final String? filterVehicle;

  bool get hasActiveFilters =>
      (filterOrigin?.isNotEmpty ?? false) ||
      (filterDestination?.isNotEmpty ?? false) ||
      (filterVehicle?.isNotEmpty ?? false) ||
      query.isNotEmpty;

  @override
  List<Object?> get props =>
      [loads, query, filterOrigin, filterDestination, filterVehicle];
}

class LoadsError extends LoadsState {
  const LoadsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LoadDetailLoading extends LoadsState {
  const LoadDetailLoading();
}

class LoadDetailLoaded extends LoadsState {
  const LoadDetailLoaded(this.load);
  final LoadEntity load;
  @override
  List<Object?> get props => [load];
}
