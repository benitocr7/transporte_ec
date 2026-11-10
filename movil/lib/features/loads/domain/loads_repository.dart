import 'load_entity.dart';

abstract class LoadsRepository {
  Future<List<LoadEntity>> getLoads({
    String? origin,
    String? destination,
    String? vehicleType,
    String? query,
  });

  Future<LoadEntity> getLoadById(String id);

  Future<void> saveLoad(String id);

  Future<void> unsaveLoad(String id);

  Future<List<LoadEntity>> getSavedLoads();
}
