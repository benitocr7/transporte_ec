import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/loads_repository.dart';
import 'loads_state.dart';

class LoadsCubit extends Cubit<LoadsState> {
  LoadsCubit(this._repository) : super(const LoadsInitial());

  final LoadsRepository _repository;

  String _query = '';
  String? _filterOrigin;
  String? _filterDestination;
  String? _filterVehicle;

  Future<void> loadLoads() async {
    emit(const LoadsLoading());
    try {
      final loads = await _repository.getLoads(
        query: _query,
        origin: _filterOrigin,
        destination: _filterDestination,
        vehicleType: _filterVehicle,
      );
      emit(LoadsLoaded(
        loads: loads,
        query: _query,
        filterOrigin: _filterOrigin,
        filterDestination: _filterDestination,
        filterVehicle: _filterVehicle,
      ));
    } catch (e) {
      emit(LoadsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> search(String query) async {
    _query = query;
    await loadLoads();
  }

  Future<void> applyFilters({
    String? origin,
    String? destination,
    String? vehicleType,
  }) async {
    _filterOrigin = origin?.isEmpty == true ? null : origin;
    _filterDestination = destination?.isEmpty == true ? null : destination;
    _filterVehicle = vehicleType?.isEmpty == true ? null : vehicleType;
    await loadLoads();
  }

  Future<void> clearFilters() async {
    _query = '';
    _filterOrigin = null;
    _filterDestination = null;
    _filterVehicle = null;
    await loadLoads();
  }

  Future<void> loadDetail(String id) async {
    emit(const LoadDetailLoading());
    try {
      final load = await _repository.getLoadById(id);
      emit(LoadDetailLoaded(load));
    } catch (e) {
      emit(LoadsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> toggleSave(String id, bool currentlySaved) async {
    if (currentlySaved) {
      await _repository.unsaveLoad(id);
    } else {
      await _repository.saveLoad(id);
    }
    // Reload current state
    final current = state;
    if (current is LoadsLoaded) {
      await loadLoads();
    } else if (current is LoadDetailLoaded) {
      await loadDetail(id);
    }
  }
}
