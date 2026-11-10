import '../../domain/load_entity.dart';
import '../../domain/loads_repository.dart';
import 'mock_loads.dart';

class LoadsRepositoryImpl implements LoadsRepository {
  final _savedIds = <String>{};

  // Local copy of mock data to allow save mutations
  final List<LoadEntity> _loads = List.from(mockLoads);

  @override
  Future<List<LoadEntity>> getLoads({
    String? origin,
    String? destination,
    String? vehicleType,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return _loads.where((load) {
      if (origin != null && origin.isNotEmpty &&
          !load.origin.toLowerCase().contains(origin.toLowerCase())) {
        return false;
      }
      if (destination != null && destination.isNotEmpty &&
          !load.destination.toLowerCase().contains(destination.toLowerCase())) {
        return false;
      }
      if (vehicleType != null && vehicleType.isNotEmpty &&
          !load.vehicleType.toLowerCase().contains(vehicleType.toLowerCase())) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!load.origin.toLowerCase().contains(q) &&
            !load.destination.toLowerCase().contains(q) &&
            !load.cargoType.toLowerCase().contains(q) &&
            !load.companyName.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).map((l) => l.copyWith(isSaved: _savedIds.contains(l.id))).toList();
  }

  @override
  Future<LoadEntity> getLoadById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final load = _loads.firstWhere((l) => l.id == id,
        orElse: () => throw Exception('Carga no encontrada'));
    return load.copyWith(isSaved: _savedIds.contains(load.id));
  }

  @override
  Future<void> saveLoad(String id) async {
    _savedIds.add(id);
  }

  @override
  Future<void> unsaveLoad(String id) async {
    _savedIds.remove(id);
  }

  @override
  Future<List<LoadEntity>> getSavedLoads() async {
    return _loads
        .where((l) => _savedIds.contains(l.id))
        .map((l) => l.copyWith(isSaved: true))
        .toList();
  }
}
