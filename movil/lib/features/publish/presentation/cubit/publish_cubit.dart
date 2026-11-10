import 'package:flutter_bloc/flutter_bloc.dart';
import 'publish_state.dart';

class PublishCubit extends Cubit<PublishState> {
  PublishCubit() : super(const PublishInitial());

  Future<void> publishLoad({
    required String origin,
    required String destination,
    required String date,
    required String cargoType,
    required String weight,
    required String price,
  }) async {
    emit(const PublishLoading());
    await Future.delayed(const Duration(milliseconds: 900));
    // Simulate publish — replace with API call
    emit(const PublishSuccess('Tu carga fue publicada exitosamente.'));
  }

  Future<void> publishVehicle({
    required String vehicleType,
    required String availability,
    required String route,
    required String capacity,
  }) async {
    emit(const PublishLoading());
    await Future.delayed(const Duration(milliseconds: 900));
    emit(const PublishSuccess('Tu vehículo fue publicado exitosamente.'));
  }

  void reset() => emit(const PublishInitial());
}
