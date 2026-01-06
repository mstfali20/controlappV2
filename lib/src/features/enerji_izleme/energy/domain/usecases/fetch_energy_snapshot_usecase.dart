import '../entities/energy_snapshot.dart';
import '../repositories/energy_repository.dart';

class FetchEnergySnapshotParams {
  const FetchEnergySnapshotParams({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  final String username;
  final String password;
  final String deviceId;
}

class FetchEnergySnapshotUseCase {
  FetchEnergySnapshotUseCase(this._repository);

  final EnergyRepository _repository;

  Future<EnergySnapshot> call(FetchEnergySnapshotParams params) {
    return _repository.fetchCurrentData(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
    );
  }
}
